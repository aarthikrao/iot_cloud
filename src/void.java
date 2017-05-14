void my_method (int employee_id, String employee_name,String employee_Dept,int employee_age){
		sql = "INSERT INTO employee_DB(" + employee_id +",'"+employee_name+"','"+employee_Dept+"',"+employee_age + ");";
		dbmethod(sql)
		System.out.println("Data inserted")
}

// call this method as my_method(1, Vaishak, CSE, 21);
// the dbmethod is them method where you do the DBconnections
