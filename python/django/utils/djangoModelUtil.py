from django.db import models
import sys

# Create specified model and the table name will be ${app_label}_${name}
def create_model(name, fields=None, app_label='', module='', options=None, admin_opts=None):
    """
    Create specified model and the table name will be ${app_label}_${name}.
    Usage:
    attrs = {
            'name': models.CharField(max_length=45),
            'des': models.CharField(max_length=45),
        }
    model1 = create_model('test1', attrs, 'AppName')
    """
    class Meta:
        # Using type('Meta', ...) gives a dictproxy error during model creation
        pass

    if app_label:
        # app_label must be set using the Meta inner class
        setattr(Meta, 'app_label', app_label)

    # Update Meta with any options that were provided
    if options is not None:
        for key, value in options.iteritems():
            setattr(Meta, key, value)

    # Set up a dictionary to simulate declarations within a class
    attrs = {'__module__': module, 'Meta': Meta}

    # Add in any fields that were provided
    if fields:
        attrs.update(fields)

    # Create the class, which automatically triggers ModelBase processing
    model = type(name, (models.Model,), attrs)

    # Create an Admin class if admin options were provided
    if admin_opts is not None:
        class Admin(admin.ModelAdmin):
            pass
        for key, value in admin_opts:
            setattr(Admin, key, value)
        admin.site.register(model, Admin)

    return model

# Create specified model and the table name will be ${table_name}
def create_model_by_template(table_name, table_schema, namespace):
    """
    Create specified model and the table name will be ${table_name}.
    Function that creates a class dynamically and injects it into namespace.
    Usually namespace is an object that corresponds to models.py's in memory object.
    Usage:
    table_schema = '''
    name = models.CharField(max_length=45)
    des = models.CharField(max_length=45)
'''
    model1 = create_model_by_template('test1', table_schema, globals())
    """
    template = '''
class %s(models.Model):
    %s
    class Meta:
        db_table = '%s'
'''
    exec template%(table_name, table_schema, table_name) in namespace
    return namespace[table_name]

# install the model to database    
def install(model, verbosity=1, interactive=False):
    from django.db import connection, transaction, models
    from django.core.management.color import no_style
    from django.core.management.sql import custom_sql_for_model, emit_post_sync_signal
    

    # Standard syncdb expects models to be in reliable locations,
    # so dynamic models need to bypass django.core.management.syncdb.
    # On the plus side, this allows individual models to be installed
    # without installing the entire project structure.
    # On the other hand, this means that things like relationships and
    # indexes will have to be handled manually.
    # This installs only the basic table definition.

    # disable terminal colors in the sql statements
    app_name = "fake_app"
    try:
        app_name = model._meta.app_label
    except Exception, e:
        print e
    style = no_style()
    cursor = connection.cursor()
    tables = connection.introspection.table_names()
    seen_models = connection.introspection.installed_models(tables)
    created_models = set()
    pending_references = {}
    db_table = connection.introspection.table_name_converter(model._meta.db_table)
    for tmp_table in tables:
        if(tmp_table.lower() == db_table.lower()):
            if verbosity >= 1:
                print "[Failed:table exist] Creating table %s for %s.%s model" % (model._meta.db_table, app_name, model._meta.object_name)
            return False
    sql, references = connection.creation.sql_create_model(model, style, seen_models)
    seen_models.add(model)
    created_models.add(model)
    for refto, refs in references.items():
        pending_references.setdefault(refto, []).extend(refs)
        if refto in seen_models:
            sql.extend(connection.creation.sql_for_pending_references(refto, style, pending_references))
    sql.extend(connection.creation.sql_for_pending_references(model, style, pending_references))
    if verbosity >= 1:
        print "Creating table %s for %s.%s model" % (model._meta.db_table, app_name, model._meta.object_name)
    for statement in sql:
        if verbosity >= 3:
            print statement
        cursor.execute(statement)
    tables.append(connection.introspection.table_name_converter(model._meta.db_table))
    sql = connection.creation.sql_for_many_to_many(model, style)
    if sql:
        if verbosity >= 2:
            print "Creating many-to-many tables for %s.%s model" % (app_name, model._meta.object_name)
        for statement in sql:
            if verbosity >= 3:
                print statement
            cursor.execute(statement)
    transaction.commit_unless_managed()
    # Send the post_syncdb signal, so individual apps can do whatever they need
    # to do at this point.
    emit_post_sync_signal(created_models, verbosity, interactive)
    # The connection may have been closed by a syncdb handler.
    cursor = connection.cursor()
    index_sql = connection.creation.sql_indexes_for_model(model, style)
    if index_sql:
        if verbosity >= 1:
            print "Installing index for %s.%s model" % (app_name, model._meta.object_name)
        try:
            for statement in index_sql:
                if verbosity >= 3:
                    print statement
                cursor.execute(statement)
        except Exception, e:
            sys.stderr.write("Failed to install index for %s.%s model: %s\n" % \
                                (app_name, model._meta.object_name, e))
            transaction.rollback_unless_managed()
        else:
            transaction.commit_unless_managed()
    return True

def test():
    attrs = {
            'name': models.CharField(max_length=45),
            'des': models.CharField(max_length=45),
        }
    #model1 = create_model('Test2', attrs, 'App1')

    table_schema = '''
    name = models.CharField(max_length=45)
    des = models.CharField(max_length=45)
'''
    model1 = create_model_by_template('Test2', table_schema, globals())
    #print model1.objects.all()[0].name
    install(model1)
