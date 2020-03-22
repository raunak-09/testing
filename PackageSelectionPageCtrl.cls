public class PackageSelectionPageCtrl {   

        
    public static String opportunityId {get;set;}
    public static String accountingCode {get;set;}
    public static String oppRPCId {get;set;}
    public static String type {get;set;}
    public String oppRatePlanChargeJSON {get;set;}
    public String packageSettingJSON {get;set;}
    public string chargeAttributeJSONMap {get;set;}
    public String packageName {get;set;}
    public String Website {get;set;}
    public Set<String> attributesList {get;set;}
    public boolean displayPopup {get; set;}
    
    public map<string,list<Opportunity_Charge_Attribute__c>> oppPdtVsOPPChargeAttr {get; set;}
    public map<string,list<invoiceit_s__Product_Rate_Plan_Charge__c>> accCodeVsProductRPCMap {get; set;}
    public  List<invoiceit_s__Product_Rate_Plan_Charge__c> productRPCList {get; set;}
    public List<invoiceit_s__Product_Rate_Plan_Charge__c> prodRPCList {get; set;}
    public String selectedProductRPC{get; set;}
    public Map<String, String> oppRPCIdVsProdRPCMap {get;set;}
    public String oppRPCIdVsProdRPCJSONMap{get;set;}
    
    public PackageSelectionPageCtrl(){
        
        opportunityId = ApexPages.currentPage().getParameters().get('Id');
        accountingCode = ApexPages.currentPage().getParameters().get('acCode');
        oppRPCId = ApexPages.currentPage().getParameters().get('oppRPCId');
        System.debug('@@@opportunity RPC Id in class'+oppRPCId);
        Map<String,List<String>> acctgCodeVsAttributes = new Map<String, List<String>>();
        System.debug('opportunity id--> ' + opportunityId);
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oppCharge = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        attributesList = new Set<String>();
        List<String> attrbs = new List<String>();
        oppPdtVsOPPChargeAttr = new Map<String, list<Opportunity_Charge_Attribute__c>>();
        Set<String> accCodes = new Set<String>();
         productRPCList = new List<invoiceit_s__Product_Rate_Plan_Charge__c>();
        accCodeVsProductRPCMap = new Map<String, List<invoiceit_s__Product_Rate_Plan_Charge__c>>();
        oppRPCIdVsProdRPCMap = new Map<String,String>();
        
        System.debug('@@@oppRPCIdVsProdRPCMap'+oppRPCIdVsProdRPCMap);
        oppRPCIdVsProdRPCJSONMap = JSON.serialize(oppRPCIdVsProdRPCMap);
        System.debug('oppRPCIdVsProdRPCJSONMap-------------->'+oppRPCIdVsProdRPCJSONMap);
        
        oppCharge = [SELECT id,name,invoiceit_crmx__Accounting_Code__c,Package_Wrapper__c,
                        invoiceit_crmx__Row_Total__c,invoiceit_crmx__Opportunity__c,
                        invoiceit_crmx__Product_Bundle_Line__c,Package_Component__c,
                        (Select Id,Name,Attribute_Name__c,string_value__c,picklist_value__c, Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id
                         From Opportunity_Charge_Attributes__r)
                        FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                        WHERE invoiceit_crmx__Opportunity__c  =: opportunityId];
        
        
        invoiceit_crmx__Opportunity_Product__c opportunityPackage = [SELECT id,name 
                                                                     FROM invoiceit_crmx__Opportunity_Product__c 
                                                                     WHERE invoiceit_crmx__Opportunity__c =: opportunityId 
                                                                     AND invoiceit_crmx__Product_Family__c = 'Package'];
            if(opportunityPackage != null){
                packageName = opportunityPackage.Name;
            }else{
                packageName = 'None';
            }
        
        List<Package_Group_Setting__c> packageSettings = Package_Group_Setting__c.getall().values();
        if(oppCharge != null && oppCharge.size() > 0){
            oppRatePlanChargeJSON = JSON.serialize(oppCharge);
        }else{
            oppRatePlanChargeJSON = '{}';                
        }
        if(packageSettings != null && packageSettings.size() > 0){
            packageSettingJSON = JSON.serialize(packageSettings);
        }else{
            packageSettingJSON = '{}';                
        }
        
        System.debug('oppCharge--> ' + JSON.serialize(oppCharge));
        System.debug('packageSetting---->'+packageSettingJSON);

        for(Package_Group_Setting__c pack: packageSettings){
            if(pack.Attributes__c != NULL && pack.Accounting_Code__c!=NULL){
                if(acctgCodeVsAttributes.containskey(pack.Accounting_Code__c)){
                    acctgCodeVsAttributes.get(pack.Accounting_Code__c).add(pack.Attributes__c);
                }else{
                    acctgCodeVsAttributes.put(pack.Accounting_Code__c, pack.Attributes__c.split(','));
                }       
            }
        }
        System.debug('@@@@@acctgCodeVsAttributes'+acctgCodeVsAttributes);
        
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opp: oppCharge){
            accCodes.add(opp.invoiceit_crmx__Accounting_Code__c);
            if(opp.Opportunity_Charge_Attributes__r.size()>0){
                if(acctgCodeVsAttributes.containskey(opp.invoiceit_crmx__Accounting_Code__c )){
                                        attrbs = acctgCodeVsAttributes.get(opp.invoiceit_crmx__Accounting_Code__c);
                    
                    for(Opportunity_Charge_Attribute__c chargAttr:  opp.Opportunity_Charge_Attributes__r){
                        System.debug('Attribute Name --->'+chargAttr.Attribute_Name__c);
                        System.debug('attributes for this charge ---->'+attrbs);
                        System.debug('=========Contains'+attrbs.contains(chargAttr.Attribute_Name__c));
                        if(attrbs.contains(chargAttr.Attribute_Name__c)){
                            if(oppPdtVsOPPChargeAttr.containsKey(chargAttr.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id)){
                                oppPdtVsOPPChargeAttr.get(chargAttr.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id).add(chargAttr);
                            }else{
                                oppPdtVsOPPChargeAttr.put(chargAttr.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id, new List<Opportunity_Charge_Attribute__c> {chargAttr});                                
                            }
                        }
                    }
                }
            }
        }
        System.debug('@@@@@@@@@@@@@Attributes'+oppPdtVsOPPChargeAttr);
        System.debug('Accounting Codes----------->'+accCodes);        
        chargeAttributeJSONMap= JSON.serialize(oppPdtVsOPPChargeAttr);
        System.debug('@@@@@@@@@@@@@JSON Attributes'+chargeAttributeJSONMap);
       //Getting the Product Rate Plan Charges for the products on the Opportunity 
        productRPCList = [Select id, name,invoiceit_s__Accounting_Code__c From invoiceit_s__Product_Rate_Plan_Charge__c Where invoiceit_s__Accounting_Code__c in:accCodes AND Package_Component__c=FALSE AND Package_Wrapper__c = FALSE AND (NOT Name like '%Annual%')];
        List<invoiceit_s__Product_Rate_Plan_Charge__c> nonWebCharges = new List<invoiceit_s__Product_Rate_Plan_Charge__c>();
        
        
        System.debug('@@@@ProductRPCList-------->'+productRPCList);
        for(invoiceit_s__Product_Rate_Plan_Charge__c prp1: productRPCList){
            if(prp1.invoiceit_s__Accounting_Code__c == '01808'){
                if(!accCodeVsProductRPCMap.containskey('01808')){
                    accCodeVsProductRPCMap.put(prp1.invoiceit_s__Accounting_Code__c,new List<invoiceit_s__Product_Rate_Plan_Charge__c>{prp1});
                }else{
                    }
            }
            else if(prp1.invoiceit_s__Accounting_Code__c == '01811'){
                if(!accCodeVsProductRPCMap.containskey('01811')){
                    accCodeVsProductRPCMap.put(prp1.invoiceit_s__Accounting_Code__c,new List<invoiceit_s__Product_Rate_Plan_Charge__c>{prp1});
                }else{
                    }
            }
            else if(prp1.invoiceit_s__Accounting_Code__c == '01972'){
                if(!accCodeVsProductRPCMap.containskey('01972')){
                    accCodeVsProductRPCMap.put(prp1.invoiceit_s__Accounting_Code__c,new List<invoiceit_s__Product_Rate_Plan_Charge__c>{prp1});
                }else{
                    }
            }
            else if(prp1.invoiceit_s__Accounting_Code__c == '01809'){
                if(!accCodeVsProductRPCMap.containskey('01809')){
                    accCodeVsProductRPCMap.put(prp1.invoiceit_s__Accounting_Code__c,new List<invoiceit_s__Product_Rate_Plan_Charge__c>{prp1});
                }else{
                    }
            }else{
                nonWebCharges.add(prp1);
            }
        }
        
        for(invoiceit_s__Product_Rate_Plan_Charge__c prp: nonWebCharges){
            if(accCodeVsProductRPCMap.containskey(prp.invoiceit_s__Accounting_Code__c)){
                accCodeVsProductRPCMap.get(prp.invoiceit_s__Accounting_Code__c).add(prp);
            }
            else{
                accCodeVsProductRPCMap.put(prp.invoiceit_s__Accounting_Code__c, new List<invoiceit_s__Product_Rate_Plan_Charge__c>{prp});
            }            
        }
        
        
        
        System.debug('@@@@accCodeVsProductRPCMap------->'+accCodeVsProductRPCMap);
        if(accCodeVsProductRPCMap.containskey(accountingCode)){
                prodRPCList = accCodeVsProductRPCMap.get(accountingCode);
         }    
        System.debug('@@@Product Rate Plan Charge list to display--->'+prodRPCList);
        
    }
    
    public List<SelectOption> getRecords()
    {
        List<SelectOption> chargeList = new List<SelectOption>();
        if(accountingCode !=Null || accountingCode!=''){
            if(accCodeVsProductRPCMap.containskey(accountingCode)){
                prodRPCList = accCodeVsProductRPCMap.get(accountingCode);
            }    
        }
        for(invoiceit_s__Product_Rate_Plan_Charge__c prp: prodRPCList){
            chargeList.add(new SelectOption(prp.Name,prp.name));
        }
        return chargeList;
    }
    
    public pageReference submit() {         
        
        selectedProductRPC = System.currentPagereference().getParameters().get('prpcId');
        string oppRPC = System.currentPagereference().getParameters().get('oppRPCId');
        //string oppId = System.currentPagereference().getParameters().get('opportunityId');
        
        System.debug('The product rate plan charge record selected  : '+oppRPC);
        System.debug('@@@@@oppRPC---->'+oppRPC);
        
         System.debug('TheselectedProductRPC  : '+selectedProductRPC);
        try{
            if(selectedProductRPC == null){
                System.debug('@@@@@oppRPC---inside null->'+selectedProductRPC);
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select one of the product rate plan charges.'));
                return null;
            }
            
            if(selectedProductRPC != null && oppRPC != null){
                System.debug('@@@@@inside the map if');
                if(!oppRPCIdVsProdRPCMap.containskey(oppRPC)){
                    oppRPCIdVsProdRPCMap.put(oppRPC, selectedProductRPC);    
                    System.debug('@@@@@@oppRPCIdVsProdRPCMap'+oppRPCIdVsProdRPCMap);
                }
                
            }
        }
        catch(exception e){
            System.debug('Exception'+e);
        }
        return Null;
        
        
    }

    public PageReference cancelPage2(){
      PageReference pageRef = new PageReference('/apex/PackageSelectionPage?id='+opportunityId);
      pageRef.setRedirect(false);
      return pageRef;  
    }
    
    
    
    @RemoteAction
    public static void saveData(String packageWrapperJSON,String selectedPackage,String opportunityId,String rpcIdVsProdRPCMap,String oppRPCIdVsProdRPCMap){
        packageWrapper wrapper = (packageWrapper)JSON.deserialize(packageWrapperJSON, packageWrapper.class);
        //Map<String,String> rpcIdVsProdRPCMap2 = (rpcIdVsProdRPCMap)JSON.deserialize(rpcIdVsProdRPCMap, rpcIdVsProdRPCMap);
        Map<String, Object> oppRPCMapVsSelecProdRPFC = new Map<String,Object>();
        System.debug('@@@@@@rpcIdVsProdRPCMap'+rpcIdVsProdRPCMap);
        if(rpcIdVsProdRPCMap!='' && rpcIdVsProdRPCMap!=Null){
            oppRPCMapVsSelecProdRPFC = (Map<String, Object>)JSON.deserializeUntyped(rpcIdVsProdRPCMap);
            System.debug('@@@@@@@@@@@@@@oppRPCMapVsSelecProdRPFC'+oppRPCMapVsSelecProdRPFC);
        }
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opportunityPackage = [SELECT id,name, invoiceit_crmx__Opportunity_Rate_Plan__c,
                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.Name,
                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Product_Rate_Plan__c,
                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,
                                                                      invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Bundle_SequenceNumber__c   
                                                                     FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                                                     WHERE invoiceit_crmx__Opportunity__c =: opportunityId
                                                                     AND Package_Wrapper__c = true
                                                                     LIMIT 1];
        
        
        List<Opportunity> opptyRec = [Select id, name,invoiceit_crmx__Recalculate__c From Opportunity where id=:opportunityId LIMIT 1];
        System.debug('@@@@@@oppRPCIdVsProdRPCMap'+oppRPCIdVsProdRPCMap);
        System.debug('@@@@@@rpcIdVsProdRPCMap------>'+rpcIdVsProdRPCMap);
       
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> combineListTobeUpdated = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        List<invoiceit_crmx__Opportunity_Product__c> oppProductUpdateList = new List<invoiceit_crmx__Opportunity_Product__c>();
        List<invoiceit_crmx__Opportunity_Rate_Plan__c> combineRatePlanListTobeUpdated = new List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
        Set<Id> setOppChargeIds = new Set<Id>();
        
        String packageName;
        String Website;
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> toBeUpdatedList;
        
        System.debug('wrapper---> ' + wrapper);
        System.debug('selectedPackage---> ' + selectedPackage);
        System.debug('@@@@@@@wrapper.aLaCarte------>'+wrapper.aLaCarte);
        if(selectedPackage == 'silver'){
            toBeUpdatedList = wrapper.silver;
            packageName = 'Silver Package';
            Website = 'Web Silver';
        }else if(selectedPackage == 'bronze'){
            toBeUpdatedList = wrapper.bronze;
            packageName = 'Bronze Package';
            Website = 'Web Bronze';
        }else if(selectedPackage == 'gold'){
            toBeUpdatedList = wrapper.gold;
            packageName = 'Gold Package';
            Website = 'Web Gold';
        }else if(selectedPackage == 'platinum'){
            toBeUpdatedList = wrapper.platinum;
            packageName = 'Platinum Package';
            Website = 'Web Platinum';
        }else if(selectedPackage == 'aLaCarte'){
            packageName = 'A-la-carte';
        }
        
        if(packageName != 'A-la-carte'){
            invoiceit_s__Product_Bundle_Line__c newPackageBundle = [Select id,name,invoiceit_s__Product_Bundle__r.Name,
                                                                     invoiceit_s__Product_Rate_Plan_Charge__c,
                                                                     invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c,
                                                                     invoiceit_s__Product_Rate_Plan__c,invoiceit_s__Product__r.invoiceit_s__Product_Code__c,
                                                                     invoiceit_s__Product_Bundle__c,
                                                                     invoiceit_s__Product_Rate_Plan__r.Name,
                                                                     invoiceit_s__Product__c,
                                                                     invoiceit_s__Product__r.Name,
                                                                     invoiceit_s__Unit_Price__c
                                                                    FROM invoiceit_s__Product_Bundle_Line__c 
                                                                    WHERE invoiceit_s__Product_Bundle__r.Name =: packageName
                                                                    AND invoiceit_s__Product__r.name =: packageName
                                                                    LIMIT 1];
                                                                   // WHERE invoiceit_s__Product_Bundle__r.Name = 'Gold Package' 
                                                                  //  AND invoiceit_s__Product__r.name = 'Gold Package'];
            opportunityPackage.Name = packageName;
            opportunityPackage.invoiceit_crmx__Product_Bundle_Line__c = newPackageBundle.Id;
            opportunityPackage.invoiceit_crmx__Product_Rate_Plan_Charge__c = newPackageBundle.invoiceit_s__Product_Rate_Plan_Charge__c;
            opportunityPackage.invoiceit_crmx__Accounting_Code__c  = newPackageBundle.invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c ;
            opportunityPackage.invoiceit_crmx__Unit_Price__c = newPackageBundle.invoiceit_s__Unit_Price__c;
            upsert opportunityPackage;
            
            invoiceit_crmx__Opportunity_Rate_Plan__c updateOppRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c ();
            updateOppRatePlan.Id = opportunityPackage.invoiceit_crmx__Opportunity_Rate_Plan__c;
            updateOppRatePlan.invoiceit_crmx__Product_Rate_Plan__c = newPackageBundle.invoiceit_s__Product_Rate_Plan__c;
            updateOppRatePlan.Name = newPackageBundle.invoiceit_s__Product_Rate_Plan__r.Name;
            upsert updateOppRatePlan;
            
            invoiceit_crmx__Opportunity_Product__c  updateOppProduct = new invoiceit_crmx__Opportunity_Product__c();
            updateOppProduct.Id = opportunityPackage.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c;
            updateOppProduct.name = newPackageBundle.invoiceit_s__Product__r.Name;
            updateOppProduct.invoiceit_crmx__Product_Code__c = newPackageBundle.invoiceit_s__Product__r.invoiceit_s__Product_Code__c;
            updateOppProduct.invoiceit_crmx__Product__c = newPackageBundle.invoiceit_s__Product__c;
            system.debug('newPackageBundle.invoiceit_s__Product_Bundle__c'+newPackageBundle.invoiceit_s__Product_Bundle__c);
            updateOppProduct.invoiceit_crmx__Product_Bundle__c = newPackageBundle.invoiceit_s__Product_Bundle__c;
            updateOppProduct.invoiceit_crmx__Bundle_SequenceNumber__c = opportunityPackage.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Bundle_SequenceNumber__c;
            upsert updateOppProduct;
            
            List<invoiceit_s__Product_Bundle_Line__c> packageLineItemList = [SELECT id, name, invoiceit_s__Product_Rate_Plan_Charge__r.Name,
                                                                        invoiceit_s__Product_Bundle__r.Name ,invoiceit_s__Product_Rate_Plan_Charge__r.Id,
                                                                        invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c,
                                                                        invoiceit_s__Product_Rate_Plan__r.Name,invoiceit_s__Product__c,
                                                                        invoiceit_s__Product__r.name,invoiceit_s__Product__r.invoiceit_s__Product_Code__c,
                                                                        invoiceit_s__Product_Bundle__c,invoiceit_s__Product_Rate_Plan__c
                                                                        FROM invoiceit_s__Product_Bundle_Line__c 
                                                                        WHERE invoiceit_s__Product_Bundle__r.Name =:packageName];
            
            Map<String,invoiceit_s__Product_Bundle_Line__c> mapRatePlanChargeToPackage = new Map<String,invoiceit_s__Product_Bundle_Line__c>();
            
            invoiceit_s__Product_Bundle_Line__c webPackageBundle = new invoiceit_s__Product_Bundle_Line__c();
            
            System.debug('packageLineItemList'+JSON.serialize(packageLineItemList));
            
            for(invoiceit_s__Product_Bundle_Line__c packageLineItem: packageLineItemList){
                if(!mapRatePlanChargeToPackage.containskey(packageLineItem.invoiceit_s__Product__r.name)){
                    mapRatePlanChargeToPackage.put(packageLineItem.invoiceit_s__Product__r.name,packageLineItem);
                    System.debug('@@@@@@@@packageLineItem.invoiceit_s__Product_B---->e'+packageLineItem.invoiceit_s__Product_Bundle__r.Name);
                    System.debug('@@@@@@@Website'+Website);
                    if(packageLineItem.invoiceit_s__Product__r.name == Website){
                        webPackageBundle = packageLineItem;
                    }
                }
                System.debug('@@@@@@@@@@@@@webPackageBundle-------> '+webPackageBundle );
                
            }
            
            //System.debug('@@@@@webSiteRPCId'+webSiteRPCId);
            System.debug('mapRatePlanChargeToPackage---> ' + mapRatePlanChargeToPackage);
            System.debug('toBeUpdatedList---> ' + toBeUpdatedList);
            
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c orpc: toBeUpdatedList){
                setOppChargeIds.add(orpc.Id);
            }
            
            List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> orpcListToBeUpdated = [Select id , name, 
                                                                                        invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Product_Rate_Plan__c,
                                                                                        invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,
                                                                                         invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name
                                                                                         From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Where Id in :setOppChargeIds];
            
            
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge : orpcListToBeUpdated){
                System.debug('@@@@@oppRatePlanCharge.name'+oppRatePlanCharge.name);
                System.debug('Whether it is in the map or not----->'+mapRatePlanChargeToPackage.containsKey(oppRatePlanCharge.name));
                if(mapRatePlanChargeToPackage.containsKey(oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name)){
                    oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c = mapRatePlanChargeToPackage.get(oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name).Id;
                    oppRatePlanCharge.Name = mapRatePlanChargeToPackage.get(oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name).invoiceit_s__Product_Rate_Plan_Charge__r.name;
                    oppRatePlanCharge.invoiceit_crmx__Product_Rate_Plan_Charge__c = mapRatePlanChargeToPackage.get(oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name).invoiceit_s__Product_Rate_Plan_Charge__r.Id;
                    oppRatePlanCharge.invoiceit_crmx__Accounting_Code__c  = mapRatePlanChargeToPackage.get(oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name).invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c;
                    combineListTobeUpdated.add(oppRatePlanCharge);
                    
                    invoiceit_crmx__Opportunity_Rate_Plan__c updateOppRatePlan2 = new invoiceit_crmx__Opportunity_Rate_Plan__c ();
                    updateOppRatePlan2.Id = oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__c;
                    updateOppRatePlan2.invoiceit_crmx__Product_Rate_Plan__c = mapRatePlanChargeToPackage.get(oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name).invoiceit_s__Product_Rate_Plan__c;
                    updateOppRatePlan2.Name = mapRatePlanChargeToPackage.get(oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name).invoiceit_s__Product_Rate_Plan__r.Name;
                    combineRatePlanListTobeUpdated.add(updateOppRatePlan2);
                    
                    invoiceit_crmx__Opportunity_Product__c  updateOppProduct2 = new invoiceit_crmx__Opportunity_Product__c();
                    updateOppProduct2.Id = oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c;
                    updateOppProduct2.name = mapRatePlanChargeToPackage.get(oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name).invoiceit_s__Product__r.Name;
                    updateOppProduct2.invoiceit_crmx__Product_Code__c = mapRatePlanChargeToPackage.get(oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name).invoiceit_s__Product__r.invoiceit_s__Product_Code__c;
                    updateOppProduct2.invoiceit_crmx__Product__c = mapRatePlanChargeToPackage.get(oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name).invoiceit_s__Product__c;
                    updateOppProduct2.invoiceit_crmx__Product_Bundle__c = mapRatePlanChargeToPackage.get(oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name).invoiceit_s__Product_Bundle__c;
                    updateOppProduct2.invoiceit_crmx__Bundle_SequenceNumber__c = opportunityPackage.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Bundle_SequenceNumber__c;
    
                    oppProductUpdateList.add(updateOppProduct2);
                }
                else if(oppRatePlanCharge.name.contains('Web Bronze') || oppRatePlanCharge.name.contains('Web Silver') || oppRatePlanCharge.name.contains('Web Gold') || oppRatePlanCharge.name.contains('Web Platinum')){
                    oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c = webPackageBundle.Id; //webSiteRPCId;
                    oppRatePlanCharge.Name = webPackageBundle.invoiceit_s__Product_Rate_Plan_Charge__r.name; //webSiteName;
                    oppRatePlanCharge.invoiceit_crmx__Product_Rate_Plan_Charge__c = webPackageBundle.invoiceit_s__Product_Rate_Plan_Charge__r.Id; //webProdRPCId;
                    oppRatePlanCharge.invoiceit_crmx__Accounting_Code__c = webPackageBundle.invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c;//webAccCode;
                    combineListTobeUpdated.add(oppRatePlanCharge);
                    
                    invoiceit_crmx__Opportunity_Rate_Plan__c updateOppRatePlan3 = new invoiceit_crmx__Opportunity_Rate_Plan__c ();
                    updateOppRatePlan3.Id = oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__c;
                    updateOppRatePlan3.invoiceit_crmx__Product_Rate_Plan__c = webPackageBundle.invoiceit_s__Product_Rate_Plan__c; //webProdRpId;
                    updateOppRatePlan3.Name = webPackageBundle.invoiceit_s__Product__r.name; //webProdRPName;
                    combineRatePlanListTobeUpdated.add(updateOppRatePlan3);
                    
                    invoiceit_crmx__Opportunity_Product__c  updateOppProduct3 = new invoiceit_crmx__Opportunity_Product__c();
                    updateOppProduct3.Id = oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c;
                    updateOppProduct3.name = webPackageBundle.invoiceit_s__Product__r.name; //webProductName;
                    updateOppProduct3.invoiceit_crmx__Product_Code__c = webPackageBundle.invoiceit_s__Product__r.invoiceit_s__Product_Code__c; //webProductCode;
                    updateOppProduct3.invoiceit_crmx__Product__c = webPackageBundle.invoiceit_s__Product__c; //webProduct;
                    updateOppProduct3.invoiceit_crmx__Product_Bundle__c = webPackageBundle.invoiceit_s__Product_Bundle__c; //webProdBundle;
                    updateOppProduct3.invoiceit_crmx__Bundle_SequenceNumber__c = opportunityPackage.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Bundle_SequenceNumber__c;
                    oppProductUpdateList.add(updateOppProduct3);
                     
                }
            }     
            System.debug('toBeUpdatedList---> ' + combineListTobeUpdated);
                                                                  
        }
        
        Set<Id> prodRPCIds = new Set<Id>();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> packageTOAlacarteList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        Map<String,String> prodRPCIdVsProdRatePlanMap = new Map<String, String>();
        Map<String,String> prodRPCIdVsProdRatePlanNameMap = new Map<String,String>();
        Map<String,Decimal> prodRPCIdVsPriceMap = new Map<String,Decimal>();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> alaCarteChargesList =  [Select id,name, invoiceit_crmx__Opportunity_Rate_Plan__c,
                                                                                    invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,
                                                                                    invoiceit_crmx__Product_Bundle_Line__c
                                                                                    FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                                                                    WHERE Id IN:wrapper.aLaCarte];
        
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge : alaCarteChargesList){
                                                                                        
            
            oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c = null;
                                                                                        
            if(oppRPCMapVsSelecProdRPFC.containskey(oppRatePlanCharge.id)){
               system.debug('===oppRPCMapVsSelecProdRPFC==='+oppRPCMapVsSelecProdRPFC);
               oppRatePlanCharge.invoiceit_crmx__Product_Rate_Plan_Charge__c = (String)oppRPCMapVsSelecProdRPFC.get(oppRatePlanCharge.id);
               prodRPCIds.add((String)oppRPCMapVsSelecProdRPFC.get(oppRatePlanCharge.id));
               packageTOAlacarteList.add(oppRatePlanCharge); 
            }/*else{//commented by saiv 01/10/2020
                system.debug('==in else===');
                oppRatePlanCharge.invoiceit_crmx__Product_Rate_Plan_Charge__c = null;
            }*/
            
            invoiceit_crmx__Opportunity_Product__c oppProduct = new invoiceit_crmx__Opportunity_Product__c();
            oppProduct.Id = oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c;  
            oppProduct.invoiceit_crmx__Product_Bundle__c = null;                                                                      
            oppProduct.invoiceit_crmx__Bundle_SequenceNumber__c = null;
            oppProductUpdateList.add(oppProduct);
            combineListTobeUpdated.add(oppRatePlanCharge);
                                                                                
        }
        if(!prodRPCIds.isempty()){
            List<invoiceit_s__Product_Rate_Plan_Charge__c> prodRPCList = [Select id, name,invoiceit_s__Product_Rate_Plan__c, invoiceit_s__Product_Rate_Plan__r.Name,
                                                                          invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__c,invoiceit_s__Unit_Price__c 
                                                                          From invoiceit_s__Product_Rate_Plan_Charge__c where id in: prodRPCIds];
            if(!prodRPCList.isempty() && prodRPCList!=Null){
                for(invoiceit_s__Product_Rate_Plan_Charge__c p: prodRPCList){
                    if(!prodRPCIdVsProdRatePlanMap.containskey(p.id)){
                        prodRPCIdVsProdRatePlanMap.put(p.id,p.invoiceit_s__Product_Rate_Plan__c);
                        prodRPCIdVsProdRatePlanNameMap.put(p.id, p.invoiceit_s__Product_Rate_Plan__r.Name);
                        prodRPCIdVsPriceMap.put(p.id,p.invoiceit_s__Unit_Price__c);
                    }
                   
                }
            }
        }
                                                                                        
        System.debug('@@@@@@prodRPCIdVsProdRatePlanMap'+prodRPCIdVsProdRatePlanMap); 
        System.debug('@@@@@prodRPCIdVsProdRatePlanNameMap----->'+prodRPCIdVsProdRatePlanNameMap);   
        
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c alacarte: packageTOAlacarteList){
            System.debug('@@@@@@@@@@inside the final alacarte List------------->'+alacarte);
            invoiceit_crmx__Opportunity_Rate_Plan__c updateOppRatePlan3 = new invoiceit_crmx__Opportunity_Rate_Plan__c ();
            updateOppRatePlan3.Id = alacarte.invoiceit_crmx__Opportunity_Rate_Plan__c;
            
            if(oppRPCMapVsSelecProdRPFC.containskey(alacarte.id)){
                updateOppRatePlan3.invoiceit_crmx__Product_Rate_Plan__c = prodRPCIdVsProdRatePlanMap.get((String)oppRPCMapVsSelecProdRPFC.get(alacarte.id));
                updateOppRatePlan3.Name = prodRPCIdVsProdRatePlanNameMap.get((String)oppRPCMapVsSelecProdRPFC.get(alacarte.id));
                if(alacarte.invoiceit_crmx__Unit_Price__c == null ){
                    alacarte.invoiceit_crmx__Unit_Price__c = prodRPCIdVsPriceMap.get((String)oppRPCMapVsSelecProdRPFC.get(alacarte.id));
                }
                alacarte.Name = prodRPCIdVsProdRatePlanNameMap.get((String)oppRPCMapVsSelecProdRPFC.get(alacarte.id));
            }
                                        
            combineRatePlanListTobeUpdated.add(updateOppRatePlan3);  
        }
        
        if(packageName != 'A-la-carte'){
            opptyRec[0].Target_Package__c = packageName;
        }else{
            opptyRec[0].Target_Package__c = 'alacarte';
        }
         
        opptyRec[0].invoiceit_crmx__Recalculate__c = TRUE;
        System.debug('Recalculate FLag---->'+opptyRec[0].invoiceit_crmx__Recalculate__c);
        System.debug('combineListTobeUpdated---> ' + combineListTobeUpdated);
        System.debug('oppProductUpdateList---> ' + oppProductUpdateList);
        upsert combineListTobeUpdated;
        upsert oppProductUpdateList;
        upsert combineRatePlanListTobeUpdated;
        update opptyRec[0];
        
        // NEw Code------------------------------------------------------------------------------------------------------------------------------
        
        //For Seq Num
        Decimal lastSeqNum;
        Decimal lastIndpProdCompSeqNum;
        List<invoiceit_crmx__Opportunity_Product__c> pkgCompsList = new List<invoiceit_crmx__Opportunity_Product__c>();
        List<invoiceit_crmx__Opportunity_Product__c> pkgIndCompsList = new List<invoiceit_crmx__Opportunity_Product__c>();
        
        List<invoiceit_crmx__Opportunity_Product__c> OppProdUpdateList = new List<invoiceit_crmx__Opportunity_Product__c>();
        for(invoiceit_crmx__Opportunity_Product__c op: [select id,Name,invoiceit_crmx__Bundle_SequenceNumber__c,
                                                        invoiceit_crmx__Opportunity__c,invoiceit_crmx__Product_Bundle__c,
                                                        invoiceit_crmx__Product_Bundle__r.Name,invoiceit_crmx__Product_Family__c,
                                                        Product_SIN__c,invoiceit_crmx__SequenceNumber__c 
                                                        from invoiceit_crmx__Opportunity_Product__c 
                                                        where invoiceit_crmx__Opportunity__c =: opportunityId order by invoiceit_crmx__SequenceNumber__c]){
            if(op.invoiceit_crmx__Product_Bundle__c != null){                
                lastSeqNum = op.invoiceit_crmx__SequenceNumber__c;
                pkgCompsList.add(op);
            }
            if(op.invoiceit_crmx__Product_Bundle__c == null){
                lastIndpProdCompSeqNum = op.invoiceit_crmx__SequenceNumber__c;
                pkgIndCompsList.add(op);
            }
        }
        // For Product rate plan and Product rate plan charge update
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> chargesList = [select id,Name,invoiceit_crmx__Accounting_Code__c,
                                                                             invoiceit_crmx__Opportunity_Rate_Plan__c,
                                                                             invoiceit_crmx__Product_Bundle_Line__c,
                                                                             invoiceit_crmx__Product_Rate_Plan_Charge__c,
                                                                             Created_From_Charge__c ,Package_Component__c ,
                                                                             Package_Wrapper__c,invoiceit_crmx__Opportunity__c,
                                                                             invoiceit_crmx__Opportunity__r.Created_From_Order__c 
                                                                             from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                                                             where invoiceit_crmx__Product_Bundle_Line__c != null 
                                                                               and Package_Wrapper__c = false and Package_Component__c = false 
                                                                             and invoiceit_crmx__Opportunity__c =: opportunityId 
                                                                             and invoiceit_crmx__Opportunity__r.Created_From_Order__c != null];
        system.debug(logginglevel.error,'---chargesList --'+chargesList );      
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> ORPCtoUpdateList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();        
        List<invoiceit_crmx__Opportunity_Rate_Plan__c> ORPUpdateList = new List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
        Set<Id> bundleLineIds = new Set<Id>();
        Set<Id> oppRatePlanIds = new Set<Id>();
        Map<Id,Id> oppRatePlanBundleLineMap = new Map<Id,Id>(); //opprateplanId,bundleLineId
        
        if(chargesList != null && chargesList.size() > 0){    
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge: chargesList){
                bundleLineIds.add(charge.invoiceit_crmx__Product_Bundle_Line__c);
                oppRatePlanIds.add(charge.invoiceit_crmx__Opportunity_Rate_Plan__c);
                oppRatePlanBundleLineMap.put(charge.invoiceit_crmx__Opportunity_Rate_Plan__c,charge.invoiceit_crmx__Product_Bundle_Line__c);
            }
            Map<Id,invoiceit_s__Product_Bundle_Line__c> prodBundleLineMap = new Map<Id,invoiceit_s__Product_Bundle_Line__c>();
            for(invoiceit_s__Product_Bundle_Line__c pbl: [select id,Name,invoiceit_s__Product_Bundle__c,invoiceit_s__Product__c,invoiceit_s__Product__r.Name,invoiceit_s__Product_Bundle__r.Name,invoiceit_s__Product_Rate_Plan__c,invoiceit_s__Product_Rate_Plan__r.Name,invoiceit_s__Product_Rate_Plan_Charge__c,invoiceit_s__Product_Rate_Plan_Charge__r.Name,invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c from invoiceit_s__Product_Bundle_Line__c]){         
                prodBundleLineMap.put(pbl.Id,pbl);          
            }
            
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge : chargesList){
                charge.Name = prodBundleLineMap.get(charge.invoiceit_crmx__Product_Bundle_Line__c).invoiceit_s__Product_Rate_Plan_Charge__r.Name;
                charge.invoiceit_crmx__Accounting_Code__c = prodBundleLineMap.get(charge.invoiceit_crmx__Product_Bundle_Line__c).invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c;
                charge.invoiceit_crmx__Product_Rate_Plan_Charge__c =  prodBundleLineMap.get(charge.invoiceit_crmx__Product_Bundle_Line__c).invoiceit_s__Product_Rate_Plan_Charge__c;
                ORPCtoUpdateList.add(charge);
            }
            Set<Id> oppProdsSet = new Set<Id>();
            for(invoiceit_crmx__Opportunity_Rate_Plan__c orp: [select id,invoiceit_crmx__Product_Rate_Plan__c,Name,invoiceit_crmx__Opportunity_Product__c from invoiceit_crmx__Opportunity_Rate_Plan__c where id IN: oppRatePlanIds]){
                orp.invoiceit_crmx__Product_Rate_Plan__c = prodBundleLineMap.get(oppRatePlanBundleLineMap.get(orp.id)).invoiceit_s__Product_Rate_Plan__c;
                orp.Name = prodBundleLineMap.get(oppRatePlanBundleLineMap.get(orp.id)).invoiceit_s__Product_Rate_Plan__r.Name;
                ORPUpdateList.add(orp);
                oppProdsSet.add(orp.invoiceit_crmx__Opportunity_Product__c);
            }
            
            if(!ORPUpdateList.isEmpty()){
                database.update(ORPUpdateList, false);
            }
            if(!ORPCtoUpdateList.isEmpty()){
                database.update(ORPCtoUpdateList, false);
            }
            //List<invoiceit_s__Product__c> invITProd = [select id,Name from invoiceit_s__Product__c where Name = 'Web Gold'];
            Set<String> webProdNames = new Set<String>{'Web Gold','Web Platinum'};
                List<invoiceit_s__Product__c> invITProd = [select id,Name from invoiceit_s__Product__c where Name IN: webProdNames ];
            Map<String,Id> invITProdMap = new Map<String,Id>();
            for(invoiceit_s__Product__c inn: invITProd){
                invITProdMap.put(inn.Name,inn.id);
            }
            // To Update Opp Prod with Seq num
            Decimal count = 1;
            for(invoiceit_crmx__Opportunity_Product__c op: [select id,Name,invoiceit_crmx__Product__c,invoiceit_crmx__Bundle_SequenceNumber__c,invoiceit_crmx__Opportunity__c,invoiceit_crmx__Product_Bundle__c,invoiceit_crmx__Product_Bundle__r.Name,invoiceit_crmx__Product_Family__c,Product_SIN__c,invoiceit_crmx__SequenceNumber__c, invoiceit_crmx__Product_Code__c from invoiceit_crmx__Opportunity_Product__c where Id IN: oppProdsSet]){
                op.invoiceit_crmx__SequenceNumber__c= lastSeqNum+count;
                if(op.invoiceit_crmx__Product_Bundle__r.Name == 'Gold Upsell - SEO' && (op.Name == 'Web Bronze' || op.Name == 'Web Gold' || op.Name == 'Web Silver')){
                    op.Name = 'Web Gold';
                    if(invITProdMap.containsKey('Web Gold'))
                        op.invoiceit_crmx__Product__c= invITProdMap.get('Web Gold');
                }
                if(op.invoiceit_crmx__Product_Bundle__r.Name == 'Platinum Upsell - SEO' && (op.Name == 'Web Bronze' || op.Name == 'Web Gold' || op.Name == 'Web Silver')){
                    op.Name = 'Web Platinum';
                    if(invITProdMap.containsKey('Web Platinum'))
                        op.invoiceit_crmx__Product__c= invITProdMap.get('Web Platinum');
                }
                
                count++;
                OppProdUpdateList.add(op);
            }
            if(!OppProdUpdateList.isEmpty()){
                database.update(OppProdUpdateList, false);
            }
        }
        // For Seq again reordering
        List<invoiceit_crmx__Opportunity_Product__c> OppProdUpdateSeqList = new List<invoiceit_crmx__Opportunity_Product__c>();
        system.debug('lastSeqNum'+lastSeqNum);
        system.debug('lastIndpProdCompSeqNum'+lastIndpProdCompSeqNum);
        //system.debug('pkgCompsList.size()'+pkgCompsList.size());        
        //Initial pkg comp seq num is
        Decimal initSeqNum = 0;
        //if(pkgCompsList != null && pkgCompsList.size() > 0)
        //initSeqNum = lastSeqNum - (pkgCompsList.size());
        
        
        for(invoiceit_crmx__Opportunity_Product__c op:pkgCompsList){
            if(op.invoiceit_crmx__Product_Family__c == 'Package'){
                initSeqNum = op.invoiceit_crmx__SequenceNumber__c;
                break;
            }
        }
        system.debug('initSeqNum '+initSeqNum );
        Decimal lastNum = 0;
        if((lastSeqNum > lastIndpProdCompSeqNum || lastSeqNum < lastIndpProdCompSeqNum) && initSeqNum > 0){
            Integer count = 1;
            for(invoiceit_crmx__Opportunity_Product__c op:pkgCompsList){
                if(op.invoiceit_crmx__SequenceNumber__c == initSeqNum){
                    //SKIP least one as it is wrapper prod
                }else{
                    op.invoiceit_crmx__SequenceNumber__c= initSeqNum+count;
                    lastNum = op.invoiceit_crmx__SequenceNumber__c;
                    OppProdUpdateSeqList.add(op);
                    count++;
                }
            }
            system.debug('lastNum '+lastNum );
            Integer Indcount = 1;
            for(invoiceit_crmx__Opportunity_Product__c op: pkgIndCompsList){
                op.invoiceit_crmx__SequenceNumber__c = lastNum+Indcount;
                OppProdUpdateSeqList.add(op);
                Indcount++;
            }
        }
        if(!OppProdUpdateSeqList.isEmpty()){
            database.update(OppProdUpdateSeqList, false);
        }
        
        // End of Sequence No Code-----------------------------------------------------------------------------------------------------------------
         
    }
    
    public PageReference Cancel() {
        return null;
    }


    public PageReference Save() {
    return new PageReference('/'+ opportunityId);
    } 
    
     public class packageWrapper{
        public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> gold;
        public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> silver;
        public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> bronze;
        public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> platinum;
        public List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> aLaCarte;
        public Map<String, String> oppRPCIdVsProdRPCId;
    }
    
    public void showPopUp(){
        displayPopup = true;
    }
    
}