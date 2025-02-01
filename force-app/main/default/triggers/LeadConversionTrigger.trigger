trigger LeadConversionTrigger on Lead (after update) {
    List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

    for (Lead lead : Trigger.new) {
        // Verifica se o Lead foi convertido e se a Oportunidade foi criada
        if (lead.IsConverted && lead.ConvertedOpportunityId != null &&
            lead.IsConverted != Trigger.oldMap.get(lead.Id).IsConverted) {
            
            try {
                // Recupera a Oportunidade associada ao Lead convertido
                Opportunity opp = [
                    SELECT Id, StageName
                    FROM Opportunity
                    WHERE Id = :lead.ConvertedOpportunityId
                    LIMIT 1
                ];

                // Verifica se o estágio da Oportunidade não está em "Negociação"
                if (opp.StageName != 'Negociação') {
                    opp.StageName = 'Negociação'; 
                    opportunitiesToUpdate.add(opp);
                }
            } catch (QueryException e) {
                System.debug('Erro ao buscar a Oportunidade: ' + e.getMessage());
            }
        }
    }

    // Atualiza as Oportunidades apenas se houver modificações
    if (!opportunitiesToUpdate.isEmpty()) {
        try {
            update opportunitiesToUpdate;  
        } catch (DmlException e) {
            System.debug('Erro ao atualizar as Oportunidades: ' + e.getMessage());
        }
    }
}