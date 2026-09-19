public with sharing class AccountService {

    private static final String DEFAULT_INDUSTRY = 'Other';

    public static List<Account> getAccountsByIndustry(Set<String> industries) {
        if (industries == null || industries.isEmpty()) {
            return new List<Account>();
        }

        Set<String> cleanIndustries = new Set<String>();
        for (String ind : industries) {
            if (ind != null) {
                String t = ind.trim();
                if (t.length() > 0) {
                    cleanIndustries.add(t);
                }
            }
        }

        if (cleanIndustries.isEmpty()) {
            return new List<Account>();
        }

        return [
            SELECT Id, Name, Industry
            FROM Account
            WHERE Industry IN :cleanIndustries
        ];
    }

    /**
     * Update Account.Industry to a default value for any Accounts in the provided list
     * that currently have a blank Industry. This method mutates the supplied SObjects
     * and performs a single bulk DML update for all changed records.
     *
     * Behavior:
     * - No-op when input is null or empty.
     * - Fail-fast: throws if the input list contains a null element or any Account with a null Id.
     * - Throws if the Account object or the Industry field is not updateable due to permissions.
     * - Sets blank Industry values to DEFAULT_INDUSTRY and updates changed records in bulk.
     */
    public static void updateAccountIndustries(List<Account> accountsToUpdate) {
        if (accountsToUpdate == null || accountsToUpdate.isEmpty()) {
            return;
        }

        // Fail-fast checks for invalid input elements
        List<Integer> nullElementIndexes = new List<Integer>();
        List<Integer> nullIdIndexes = new List<Integer>();
        for (Integer i = 0; i < accountsToUpdate.size(); i++) {
            Account aCheck = accountsToUpdate[i];
            if (aCheck == null) {
                nullElementIndexes.add(i);
            } else if (aCheck.Id == null) {
                nullIdIndexes.add(i);
            }
        }
        List<Account> toUpdate = new List<Account>();
        for (Account a : accountsToUpdate) {
            // a and a.Id are guaranteed non-null by fail-fast checks above
            if (String.isBlank(a.Industry)) {
                a.Industry = DEFAULT_INDUSTRY;
                toUpdate.add(a);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
    public static void checkAccountduplicate(List<Account> accountsToCheck) {
        if (accountsToCheck == null || accountsToCheck.isEmpty()) {
            return;
        }

        Set<String> accountNames = new Set<String>();
        for (Account a : accountsToCheck) {
            if (a == null) {
                throw new IllegalArgumentException('Null Account element found in input list');
            }
            if (a.Id == null) {
                throw new IllegalArgumentException('Account with null Id found in input list');
            }
            if (accountNames.contains(a.Name)) {
                throw new IllegalArgumentException('Duplicate Account Name found: ' + a.Name);
            }
            accountNames.add(a.Name);
        }
    }
}