public with sharing class AccountService {
    public AccountService() {

    }

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
}