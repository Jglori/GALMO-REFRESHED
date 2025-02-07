public class ExtratoTabelaService {

    public class ComparacaoResultado {
        @auraEnabled
        public String criterio { get; set; }
        @auraEnabled
        public Decimal valorTabela {get; set;} 
        @auraEnabled
        public Decimal valorProposta {get; set;} 
        @auraEnabled
        public Boolean dentroDoLimite {get; set;}
        // @auraEnabled
        // public String aprovado {get; set;}
    }

    // Método auxiliar para criar ComparacaoResultado com formatação
    private static ComparacaoResultado criarComparacao(String criterio, Decimal valorTabela, Decimal valorProposta, Boolean isInLimit) {
        ComparacaoResultado resultado = new ComparacaoResultado();
        resultado.criterio = criterio;
        resultado.valorTabela = valorTabela.setScale(2);  // Formatação com 2 casas decimais
        resultado.valorProposta = valorProposta.setScale(2);  // Formatação com 2 casas decimais
        resultado.dentroDoLimite = isInLimit;
        // resultado.aprovado = resultado.dentroDoLimite ? 'utility:success' : 'utility:error';
        return resultado;
    }

    // realisa a analise entre valores da tabela de venda e da proposta do cliente
    public static List<Object> analisarProposta(Id tabelaId, List<SeriePagamentos__c> proposta, Map<String, Object> valoresMatriz, ConjuntoCriteriosAnalise__c conjuntoCriterios) {
        List<ComparacaoResultado> resultados = new List<ComparacaoResultado>();
        List<SeriePagamentos__c> series = SeriePagamentoSelector.obterSeriePagamentosPorInicioPagamento(tabelaId);

        Decimal nominalTabela, nominalProposta, valorVplTabela, valorVplProposta = 0.0;

        if (valoresMatriz != null) {
            nominalTabela = valoresMatriz.get('nominalTabela') instanceof Decimal ? (Decimal) valoresMatriz.get('nominalTabela') : Decimal.valueOf( (String) valoresMatriz.get('nominalTabela') );
            nominalProposta = valoresMatriz.get('nominalProposta') instanceof Decimal ? (Decimal) valoresMatriz.get('nominalProposta') : Decimal.valueOf( (String) valoresMatriz.get('nominalProposta') ); 
            valorVplTabela = valoresMatriz.get('valorVplTabela') instanceof Decimal ? (Decimal) valoresMatriz.get('valorVplTabela') : Decimal.valueOf( (String) valoresMatriz.get('valorVplTabela') );
            valorVplProposta = valoresMatriz.get('vplProposta') instanceof Decimal ? (Decimal) valoresMatriz.get('vplProposta') : Decimal.valueOf( (String) valoresMatriz.get('vplProposta') );

        } else {
            System.debug('valoresMatriz é null');
        }
        
        Decimal quantidadeParcelas = 0.0;
        Decimal quantidadeParcelasProp = 0.0;
        Decimal captacaoVistaTabela = 0.0;
        Decimal captacaoVistaProposta = 0.0;
        Decimal captacaoMensalTabela = 0.0;
        Decimal captacaoMensalProposta = 0.0;
        Decimal captacaoAteHabTabela = 0.0;
        Decimal captacaoAteHabProposta = 0.0;
        
        // Processando todas as séries em uma única iteração
        for (SeriePagamentos__c s : series) {
            quantidadeParcelas += s.QuantidadeParcelas__c != null ? s.QuantidadeParcelas__c : 0;

            if (s.TipoCondicao__c == 'Ato') {
                captacaoVistaTabela = s.ValorTotal__c != null ? s.ValorTotal__c : 0;
            }
            if (s.TipoCondicao__c == 'Mensais') {
                captacaoMensalTabela += s.ValorTotal__c != null ? s.ValorTotal__c : 0;
            }
            if (!s.AposHabiteSe__c) {
                captacaoAteHabTabela += s.ValorTotal__c != null ? s.ValorTotal__c : 0;
            }
        }

        for (SeriePagamentos__c s : proposta) {
            quantidadeParcelasProp += s.QuantidadeParcelas__c != null ? s.QuantidadeParcelas__c : 0;

            if (s.TipoCondicao__c == 'Ato') {
                captacaoVistaProposta = (s.ValorTotal__c != null ? s.ValorTotal__c : 0) / 100;  // Dividindo por 100
            }
            if (s.TipoCondicao__c == 'Mensais') {
                captacaoMensalProposta += (s.ValorTotal__c != null ? s.ValorTotal__c : 0) / 100;  // Dividindo por 100
            }
            if (!s.AposHabiteSe__c) {
                captacaoAteHabProposta += (s.ValorTotal__c != null ? s.ValorTotal__c : 0) / 100;  // Dividindo por 100
            }
        }

        Boolean valorNominalInLimit = handleCriteriosPorcentagem((Double) nominalTabela, (Double) nominalProposta, (Double) conjuntoCriterios.valorNominal__c, conjuntoCriterios.VariacaoLimiteValorNominal__c);
        Boolean valorVplInLimit = handleCriteriosPorcentagem((Double) valorVplTabela, (Double) valorVplProposta, (Double) conjuntoCriterios.ValorVpl__c, conjuntoCriterios.VariacaoLimiteValorVPL__c);
        Boolean prazoInLimit = handleCriterios((Double) quantidadeParcelas, (Double) quantidadeParcelasProp, (Double) conjuntoCriterios.PrazoFinanciamento__c, conjuntoCriterios.VariacaoLimitePrazoFinanciamento__c);
        Boolean captacaoVistaInLimit = handleCriteriosPorcentagem((Double) captacaoVistaTabela, (Double) captacaoVistaProposta, (Double) conjuntoCriterios.CaptacaoVista__c, conjuntoCriterios.VariacaoLimiteCaptacaoVista__c);
        Boolean captacaoHabitaSeInLimit = handleCriteriosPorcentagem((Double) captacaoAteHabTabela, (Double) captacaoAteHabProposta, (Double) conjuntoCriterios.CaptacaoPosHabitaSe__c, conjuntoCriterios.VariacaoLimiteCaptacaoPos__c);
        Boolean captacaoMensalInLimit = handleCriteriosPorcentagem((Double) captacaoMensalTabela, (Double) captacaoMensalProposta, (Double) conjuntoCriterios.CaptacaoMensal__c, conjuntoCriterios.VariacaoLimiteCaptacaoMensal__c);

        resultados.add(criarComparacao('Valor nominal', nominalTabela, nominalProposta, valorNominalInLimit));
        resultados.add(criarComparacao('Valor VPL', valorVplTabela, valorVplProposta, valorVplInLimit));
        resultados.add(criarComparacao('Prazo de financiamento', quantidadeParcelas, quantidadeParcelasProp, prazoInLimit));
        resultados.add(criarComparacao('% de Captação à vista', captacaoVistaTabela, captacaoVistaProposta, captacaoVistaInLimit));
        resultados.add(criarComparacao('% de Captação até habita-se', captacaoAteHabTabela, captacaoAteHabProposta, captacaoHabitaSeInLimit));
        resultados.add(criarComparacao('% de Captação mensal', captacaoMensalTabela, captacaoMensalProposta, captacaoMensalInLimit));
        
        return resultados;
    }

    @TestVisible
    private static Boolean handleCriterios(Double tabela, Double proposta, Double criterioLimite, String criterioValorLimite) {
        Decimal result = tabela - proposta;
        // Se a condição é 'Não for igual' retorna True quando o result é IGUAL a 0 (dentro do limite)
        if (criterioValorLimite == 'Não for igual') return result == 0.0;
        // Verifica se a codição é 'Acima do limite' e retorna True quando o result é MENOR ou IGUAL ao limite (dentro do limite) 
        else if (criterioValorLimite == 'Acima do limite') return result <= criterioLimite;
        // Se não, a condição é 'Abaixo do limite' e retorna True quando o result é MAIOR ou IGUAL ao limite (dentro do limite)
        else return result >= criterioLimite;
    }

    @TestVisible
    private static Boolean handleCriteriosPorcentagem(Double tabela, Double proposta, Double criterioLimite, String criterioValorLimite) {
        Decimal result = tabela - proposta;
        if (result > 0.0) result /= 100;
        // Se a condição é 'Não for igual' retorna True quando o result é IGUAL a 0 (dentro do limite)
        if (criterioValorLimite == 'Não for igual') return result == 0.0;
        // Verifica se a codição é 'Acima do limite' e retorna True quando o result é MENOR ou IGUAL ao limite (dentro do limite) 
        else if (criterioValorLimite == 'Acima do limite') return result <= criterioLimite;
        // Se não, a condição é 'Abaixo do limite' e retorna True quando o result é MAIOR ou IGUAL ao limite (dentro do limite)
        else return result >= criterioLimite;
    }


}