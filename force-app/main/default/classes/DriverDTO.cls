public with sharing class DriverDTO {
    public String firstName;
    public String lastName;
    public Integer age;
    
    public DriverDTO(String firstName, String lastName, Integer age) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.age = age; 
    }
}
