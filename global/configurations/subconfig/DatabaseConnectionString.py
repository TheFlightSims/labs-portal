from sqlalchemy.engine import URL

class DatabaseConnectionString:
    '''
    Constructor of the database class
    It includes
        1. The dialect of the SQL server. 
            It is either 
            - "postgresql" for PostgreSQL
            - "mysql" for MySQL
            - "mssql" for Microsoft SQL Server
            - "oracle" for Oracle SQL
        2. Driver of the SQL Server. It acts as the connection middle-end for between the database and the JupyterHub service
        3. Username for connection to the SQL Server
        4. Password of the that user name
        5. Host for the target database host. It can be IPv4, IPv6, or DNS name
        6. Port of the database server
        7. Database name as target database
    '''
    def __init__(self, dialect, driver, username, password, host, port, dbName):
        self.dialect = dialect
        self.driver = driver
        self.username = username
        self.password = password
        self.host = host
        self.port = port
        self.dbName = dbName

    '''
    Private Method - Get the connection URL from the dialect and driver
    If the driver is not specified, SQLalchemy will use the default
    '''
    def __get_connection_url__(self):
        connection_url = self.dialect
        if self.driver != None:
            connection_url += "+" + self.driver
        return self.connection_url

    '''
    Public Method - Get the Microsoft SQL Server connection string
    '''
    def get_mssql_connection_url(
        self,
        odbc_driver="ODBC Driver 18 for SQL Server",
        encrypt="yes",
        trust_server_certificate="yes",
    ):
        connection_url = self.__get_connection_url__()

        connection_url = URL.create(
            connection_url,
            username=self.username,
            password=self.password,
            host=self.password,
            port=self.port,
            database=self.dbName,
            query = {
                "driver": odbc_driver,
                "Encrypt": encrypt,
                "TrustServerCertificate": trust_server_certificate,
            },
        )

        return connection_url

    '''
    Public Method - Get the PostgreSQL connection string
    '''
    def get_postgres_connection_url(self):
        connection_url = self.__get_connection_url__()

        connection_url = URL.create(
            connection_url,
            username=self.username,
            password=self.password,
            host=self.password,
            port=self.port,
            database=self.dbName
        )

        return connection_url

    '''
    Public Method - Get the MySQL Server connection string
    '''
    def get_mysql_connection_url(self):
        connection_url = self.__get_connection_url__()

        connection_url = URL.create(
            connection_url,
            username=self.username,
            password=self.password,
            host=self.password,
            port=self.port,
            database=self.dbName
        )

        return connection_url

    '''
    Public Method - Get the Oracle SQL connection string
    '''
    def get_oracle_connection_url(self):
        connection_url = self.__get_connection_url__()

        connection_url = URL.create(
            connection_url,
            username=self.username,
            password=self.password,
            host=self.password,
            port=self.port,
            database=self.dbName
        )

        return connection_url
