<cfscript>
    custom = {};
    custom['useUnicode'] = "true";
    custom['useLegacyDatetimeCode'] = "true";
    custom['characterEncoding'] = "UTF-8";    
</cfscript>
<cfadmin
    action="updateDatasource"
    type="web"
    password="J5HIsmsWk26"
    classname="org.gjt.mm.mysql.Driver"
    dsn="jdbc:mysql://{host}:{port}/{database}"
    name="cfboom_test"
    newName="cfboom_test"
    host="localhost"
    database="cfboom_test"
    port="3306"
    storage="false"
    dbusername="root"
    dbpassword=""
    connectionLimit="-1"
    connectionTimeout="1"
    blob="true"
    clob="true"
    allowed_select="true"
    allowed_insert="true"
    allowed_update="true"
    allowed_delete="true"
    allowed_alter="true"
    allowed_drop="true"
    allowed_revoke="true"
    allowed_create="true"
    allowed_grant="true"
    custom="#custom#">