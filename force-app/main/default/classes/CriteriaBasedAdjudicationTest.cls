@isTest
public class CriteriaBasedAdjudicationTest {

    @isTest
    static void test_evaluate() {
        Account patient = TestFactory.newPatient('Patient 1');
        Account provider = TestFactory.newProvider('Provider 1');
        insert new Account[] { patient, provider };
        
        Drug__c drug = TestFactory.newDrug('Drug 1');
        drug.Adjudication_Strategy__c = 'Criteria';
        drug.Criteria_Logic__c = 'AND(1, 2)';
        insert drug;

        Adjudication_Criteria__c ac1 = TestFactory.newCriteria(drug, 1, 'Case', 'Origin', null, 'equals', 'Fax');
        Adjudication_Criteria__c ac2 = TestFactory.newCriteria(drug, 2, 'Case', 'Priority', null, 'equals', 'Medium');
        insert new Adjudication_Criteria__c[] {ac1, ac2};

        Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
        saCase.Origin = 'Fax';
        saCase.Priority = 'Medium';
        insert saCase;
        
        Test.startTest();
        AdjudicationStrategy strategy = new CriteriaBasedAdjudication();
        strategy.evaluate(SpecialAuthorityRequest.build(drug, patient, provider, saCase, new Request_Detail__c[]{}));
        Test.stopTest();

        system.assertEquals('Approved', saCase.Status);
    }

    @isTest
    static void test_evaluate_negative() {
        Account patient = TestFactory.newPatient('Patient 1');
        Account provider = TestFactory.newProvider('Provider 1');
        insert new Account[] { patient, provider };
        
        Drug__c drug = TestFactory.newDrug('Drug 1');
        drug.Adjudication_Strategy__c = 'Criteria';
        drug.Criteria_Logic__c = 'AND(1, 2)';
        insert drug;

        Adjudication_Criteria__c ac1 = TestFactory.newCriteria(drug, 1, 'Case', 'Origin', null, 'equals', 'Fax');
        Adjudication_Criteria__c ac2 = TestFactory.newCriteria(drug, 2, 'Case', 'Priority', null, 'equals', 'Medium');
        insert new Adjudication_Criteria__c[] {ac1, ac2};

        Case saCase = TestFactory.newCase(drug, patient, provider, 'Test case 1');
        saCase.Origin = 'Fax';
        saCase.Priority = 'Low';
        insert saCase;
        
        Test.startTest();
        AdjudicationStrategy strategy = new CriteriaBasedAdjudication();
        strategy.evaluate(SpecialAuthorityRequest.build(drug, patient, provider, saCase, new Request_Detail__c[]{}));
        Test.stopTest();

        system.assertNotEquals('Approved', saCase.Status);
    }
}