#include <iostream>
#include <mysql.h>

int main()
{
	MYSQL*  m_Mysql = NULL;

	if ((m_Mysql = mysql_init(NULL)) == 0)
	{
		std::cout<<("mysql_init() error")<<std::endl;
		return false;
	}

	//设置mysql自动重连
	char value = 1;
	if (mysql_options(m_Mysql, MYSQL_OPT_RECONNECT, (char*)&value) != 0)
	{
		std::cout<<"mysql_options error:"<< mysql_error(m_Mysql)<<std::endl;
		return false;
	}

	//连接数据库
	if (mysql_real_connect(m_Mysql, "127.0.0.1", "qqhe_test", "test_liujie@123", "nanchang", 3306, NULL, 0) == 0)
	{
		std::cout << "mysql_real_connect error:"<< mysql_error(m_Mysql)<<std::endl;
		return false;
	}

	//设置mysql字符集 
	if (mysql_set_character_set(m_Mysql, "utf8mb4") != 0)
	{
		std::cout<<"mysql_set_character_set error"<< mysql_error(m_Mysql)<<std::endl;
		return false;
	}
	std::cout<<std::endl;
	mysql_close(m_Mysql);
	return 0;
}
