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
        for (Integer i = 0; i < total; i++) {
            String ind = 'Industry' + String.valueOf(i % 4); // 4 industries
            many.add(new Account(Name = 'Acct' + i, Industry = ind));
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
}
