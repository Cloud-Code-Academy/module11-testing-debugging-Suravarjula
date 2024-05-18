@IsTest
public with sharing class LeadTriggerHandlerTest {
    @TestSetup
    static void loadTestData() {
        Account acct = new Account(Name='Test Account');
        insert acct;

        List<Contact> contacts = new List<Contact>{new Contact(FirstName='FName 9', LastName ='LName 9', Email='LName1@Test.com', AccountId = acct.Id),
                                                    new Contact(FirstName='FName 99', LastName ='LName 99', Email='LName89@Test.com', AccountId = acct.Id),
                                                    new Contact(FirstName='FName 98', LastName ='LName 98', Email='LName100@Test.com', AccountId = acct.Id),
                                                    new Contact(FirstName='FName 5', LastName ='LName 5', Email='LName5@Test.com', AccountId = acct.Id)
                                                  };
        insert contacts;
        List<Lead> leads = new List<Lead>{new Lead(FirstName='FName 1', LastName='LName 1', Company='Test Company', Status='Open', Title='vp', Email = 'LName1@Test.com', Industry='Technology' ),
                                                new Lead(FirstName='FName 2', LastName='LName 2', Company='Test Company', Status='Open', Title='v.p', Email = 'LName2@Test.com' ),
                                                new Lead(FirstName='FName 3', LastName='LName 3', Company='Test Company', Status='Open', Title='v.p.', Email = 'LName3@Test.com' ),
                                                new Lead(FirstName='FName 4', LastName='LName 4', Company='Test Company', Status='Open', Title='vice president', Email = 'LName4@Test.com', Industry='Technology' ),
                                                new Lead(FirstName='FName 5', LastName='LName 5', Company='Test Company', Status='Open', Title='mgr', Email = 'LName5@Test.com' ),
                                                new Lead(FirstName='FName 6', LastName='LName 6', Company='Test Company', Status='Open', Title='manager', Email = 'LName6@Test.com' ),
                                                new Lead(FirstName='FName 7', LastName='LName 7', Company='Test Company', Status='Open', Title='head of department' , Email = 'LName7@Test.com'),
                                                new Lead(FirstName='FName 8', LastName='LName 8', Company='Test Company', Status='Open', Title='exec', Email = 'LName8@Test.com' ),
                                                new Lead(FirstName='FName 9', LastName='LName 9', Company='Test Company', Status='Open', Title='chief' , Email = 'LName9@Test.com', Phone='+9087639899'),
                                                new Lead(FirstName='FName 10', LastName='LName 10', Company='Test Company', Status='Open', Title='head' , Email = 'LName10@Test.com'),
                                                new Lead(FirstName='FName 11', LastName='LName 11', Company='Test Company', Status='Open', Title='assistant' , Email = 'LName11@Test.com'),
                                                new Lead(FirstName='FName 12', LastName='LName 13', Company='Test Company', Status='Open', Title='deputy' , Email = 'LName13@Test.com'),
                                                new Lead(FirstName='FName 13', LastName='LName 14', Company='Test Company', Status='Open', Title='jr', Email = 'LName14@Test.com', Phone='+987654321' )
                                            };

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(leads, dml);
    }

    @IsTest
    static void testHandleTitleNormalization() {
        List<Lead> testLeads = [SELECT Id, Company, Title from Lead where Company = 'Test Company'];
        System.assertEquals(13,testLeads.size());
        System.assertEquals('Manager', testLeads.get(5).Title, 'Title is not set properly');
        System.assertEquals('v.p', testLeads.get(1).Title, 'Expected title as v.p but found normalized');
    }

    @IsTest
    static void testHandleAutoLeadScoring() {
        List<Lead> testLeads1 = [SELECT Id, Company, Title from Lead where Company = 'Test Company' and Lead_Score__c = 3];
        List<Lead> testLeads2 = [SELECT Id, Company, Title from Lead where Company = 'Test Company' and Lead_Score__c = 5];
        List<Lead> testLeads3 = [SELECT Id, Company, Title from Lead where Company = 'Test Company' and Lead_Score__c = 10];
        System.assertEquals(0, testLeads1.size(), 'No leads should be there with Score as 3');
        System.assertEquals(2, testLeads2.size(), 'No leads should be there with Score as 5');
        System.assertEquals(11, testLeads3.size(), 'Expected 13 leads with Score as 10');
    }

    @IsTest
    static void testHandleLeadAutoConvert() {
        List<Lead> leadsToUpdate = [SELECT Id, Email from Lead where Title = 'Assistant'];
        for(Lead leadRec : leadsToUpdate) {
            leadRec.Email = 'LName100@Test.com';
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.update(leadsToUpdate, dml);

        List<Lead> convertedLeads = [select Id, FirstName, LastName, MasterRecordId, IsConverted, Status, ConvertedAccountId from lead where isConverted = true];
        System.assertEquals(5, convertedLeads.size(), 'At least 5 leads should have been converted');
    }
}