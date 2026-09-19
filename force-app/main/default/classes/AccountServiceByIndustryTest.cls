@IsTest
public class AccountServiceByIndustryTest {
    @IsTest static void testGetAccountsByIndustry_MultipleIndustries() {
        Account a1 = new Account(Name='Acme', Industry='Manufacturing');
        Account a2 = new Account(Name='BetaCorp', Industry='Technology');
        Account a3 = new Account(Name='Other', Industry='Retail');
        insert new List<Account>{a1, a2, a3};

        Set<String> industries = new Set<String>{'Manufacturing', 'Technology'};

        Test.startTest();
        List<Account> results = AccountService.getAccountsByIndustry(industries);
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Should return two accounts for specified industries');

        Boolean foundA1 = false;
        Boolean foundA2 = false;
        for (Account a : results) {
            if (a.Name == 'Acme') foundA1 = true;
            if (a.Name == 'BetaCorp') foundA2 = true;
            System.assertNotEquals(null, a.Id, 'Returned account must have Id');
            System.assertNotEquals(null, a.Name, 'Returned account must have Name');
            System.assertNotEquals(null, a.Industry, 'Returned account must have Industry');
        }

        System.assert(foundA1, 'Acme should be returned');
        System.assert(foundA2, 'BetaCorp should be returned');
    }

    @IsTest static void testGetAccountsByIndustry_NullInput() {
        Test.startTest();
        List<Account> resNull = AccountService.getAccountsByIndustry(null);
        Test.stopTest();

        System.assertNotEquals(null, resNull, 'Should not return null for null input');
        System.assertEquals(0, resNull.size(), 'Null input returns empty list');
    }

    @IsTest static void testGetAccountsByIndustry_EmptySet() {
        Test.startTest();
        List<Account> resEmpty = AccountService.getAccountsByIndustry(new Set<String>());
        Test.stopTest();

        System.assertNotEquals(null, resEmpty, 'Should not return null for empty set');
        System.assertEquals(0, resEmpty.size(), 'Empty set returns empty list');
    }

    @IsTest static void testGetAccountsByIndustry_OnlyBlankOrNull() {
        Set<String> onlyBlank = new Set<String>{' ', null, '   '};

        Test.startTest();
        List<Account> resOnlyBlank = AccountService.getAccountsByIndustry(onlyBlank);
        Test.stopTest();

        System.assertNotEquals(null, resOnlyBlank, 'Should not return null for only-blank input');
        System.assertEquals(0, resOnlyBlank.size(), 'Only-blank/null input returns empty list');
    }

    @IsTest static void testGetAccountsByIndustry_MixedBlankAndValid() {
        Account a4 = new Account(Name='Retailer', Industry='Retail');
        insert a4;
        Set<String> mixed = new Set<String>{' ', null, 'Retail'};

        Test.startTest();
        List<Account> resMixed = AccountService.getAccountsByIndustry(mixed);
        Test.stopTest();

        System.assertEquals(1, resMixed.size(), 'Should handle blank/null entries and return matching records');
        System.assertEquals('Retail', resMixed[0].Industry, 'Returned account should have matching Industry');
    }

    @IsTest static void testGetAccountsByIndustry_Bulk200Accounts() {
        List<Account> many = new List<Account>();
        Integer total = 200;
        String ind = 'Industry0';
        for (Integer i = 0; i < total; i++) {
           

            if (i >= 50 && i < 100) {
                ind = 'Industry1';
            } else if (i >= 100 && i < 150) {
                ind = 'Industry2';
            } else if (i >= 150) {
                ind = 'Industry3';
            }
        }
        insert many;

        // select two of the industries
        Set<String> industries = new Set<String>{'Industry0', 'Industry2'};

        Test.startTest();
        List<Account> results = AccountService.getAccountsByIndustry(industries);
        Test.stopTest();

        Integer expected = 0;
        for (Account a : many) {
            if (a.Industry == 'Industry0' || a.Industry == 'Industry2') expected++;
        }

        System.assertEquals(expected, results.size(), 'Bulk test should return expected number of accounts');
    }

    // Tests for updateAccountIndustries
    @IsTest static void testUpdateAccountIndustries_Positive() {
        Account a1 = new Account(Name='U1'); // Industry null
        Account a2 = new Account(Name='U2', Industry='Sales');
        Account a3 = new Account(Name='U3', Industry='  ');
        insert new List<Account>{a1, a2, a3};

        List<Account> toUpdate = new List<Account>{a1, a2, a3};

        Test.startTest();
        AccountService.updateAccountIndustries(toUpdate);
        Test.stopTest();

        List<Account> re = [SELECT Id, Industry FROM Account WHERE Id IN :new Set<Id>{a1.Id, a2.Id, a3.Id}];
        Map<Id, Account> m = new Map<Id, Account>(re);

        System.assertEquals('Other', m.get(a1.Id).Industry, 'Null Industry should be set to Other');
        System.assertEquals('Sales', m.get(a2.Id).Industry, 'Existing Industry should remain unchanged');
        System.assertEquals('Other', m.get(a3.Id).Industry, 'Blank Industry should be set to Other');
    }

    @IsTest static void testUpdateAccountIndustries_NullAndEmpty() {
        Account a = new Account(Name='NoChange');
        insert a;

        // null input should do nothing
        Test.startTest();
        AccountService.updateAccountIndustries(null);
        Test.stopTest();

        Account re1 = [SELECT Id, Industry FROM Account WHERE Id = :a.Id];
        System.assertEquals(null, re1.Industry, 'Null input should not change records');

        // empty list should do nothing
        Test.startTest();
        AccountService.updateAccountIndustries(new List<Account>());
        Test.stopTest();

        Account re2 = [SELECT Id, Industry FROM Account WHERE Id = :a.Id];
        System.assertEquals(null, re2.Industry, 'Empty list input should not change records');
    }

    @IsTest static void testUpdateAccountIndustries_Bulk200() {
        List<Account> many = new List<Account>();
        Integer total = 200;
        String industry = 'Industry0';
        for (Integer i = 0; i < total; i++) {
            

            if (Math.mod(i, 5) == 1) {
                industry = 'Industry1';
            } else if (Math.mod(i, 5) == 2) {
                industry = 'Industry2';
            } else if (Math.mod(i, 5) == 3) {
                industry = 'Industry3';
            } else if (Math.mod(i, 5) == 4) {
                industry = 'Industry4';
            }
        }
        insert many;
        // compute expected before calling update (fail-safe against in-memory mutation)
        Integer expected = 0;
        for (Account a : many) {
            if (a.Industry == null) expected++;
        }

        // call update with the inserted records
        Test.startTest();
        AccountService.updateAccountIndustries(many);
        Test.stopTest();

        Integer actual = [SELECT count() FROM Account WHERE Id IN :new Map<Id, Account>(many).keySet() AND Industry = 'Other'];
        System.assertEquals(expected, actual, 'Bulk update should set Industry to Other for blank entries');
    }

    @IsTest static void testUpdateAccountIndustries_ThrowsOnNullElement() {
        Account a1 = new Account(Name='T1');
        insert a1;
        List<Account> listWithNull = new List<Account>{a1, null};

        Test.startTest();
        try {
            AccountService.updateAccountIndustries(listWithNull);
            Test.stopTest();
            System.assert(false, 'Expected exception for null Account element');
        } catch (Exception e) {
            Test.stopTest();
            System.assert(e.getMessage().contains('null Account element'), 'Exception message should mention null Account element');
        }
    }

    @IsTest static void testUpdateAccountIndustries_ThrowsOnNullId() {
        Account a1 = new Account(Name='T2');
        insert a1;
        Account noId = new Account(Name='Transient'); // not inserted, Id == null
        List<Account> listWithNoId = new List<Account>{a1, noId};

        Test.startTest();
        try {
            AccountService.updateAccountIndustries(listWithNoId);
            Test.stopTest();
            System.assert(false, 'Expected exception for Account with null Id');
        } catch (Exception e) {
            Test.stopTest();
            System.assert(e.getMessage().contains('null Id'), 'Exception message should mention null Id');
        }
    }
}
