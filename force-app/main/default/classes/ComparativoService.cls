public class ComparativoService {
    
    public class ComparacaoResultado {
        @AuraEnabled
        public String item { get; set; } 
        @AuraEnabled
        public Double valorTabela { get; set; }
        @AuraEnabled
        public Double valorProposta { get; set; }
        @AuraEnabled
        public Double diferenca { get; set; }
    }

    public static List<ComparacaoResultado> calcularComparacao(Id tabelaId, List<SeriePagamentos__c> proposta, Map<String, Object> valoresMatriz, Product2 produtoSelecionado) {

        Decimal nominalProposta = valoresMatriz.get('nominalProposta') instanceof Decimal ? (Decimal) valoresMatriz.get('nominalProposta') : Decimal.valueOf((String) valoresMatriz.get('nominalProposta'));
        Decimal nominalTabela = valoresMatriz.get('nominalTabela') instanceof Decimal ? (Decimal) valoresMatriz.get('nominalTabela') : Decimal.valueOf( (String) valoresMatriz.get('nominalTabela') );

        System.debug(tabelaId);
        System.debug(produtoSelecionado.Id);

        TabelaVendas__c tabelaVenda = TabelaVendaSelector.obterTabelasRelacionadas(tabelaId);
        UnidadeTabelaVendas__c unidadeTabelaVendaProduto = UnidadeTabelaSelector.obterUnidadeTabelaVendaPorIdTabelaEIdProduto(tabelaId, produtoSelecionado.Id);
        Empreendimento__c empreendimentoProduto = [select DataHabitase__c from Empreendimento__c where id = :produtoSelecionado.Empreendimento__c LIMIT 1];

        List<SeriePagamentosService.ObjetoSerie> propostasConvertidas = new List<SeriePagamentosService.ObjetoSerie>();

        for(SeriePagamentos__c item : proposta){
            SeriePagamentosService.ObjetoSerie obj = new SeriePagamentosService.ObjetoSerie();
            
            obj.valorTotal = (Double)item.ValorTotal__c;
            obj.quantidadeParcelas = (Integer)item.QuantidadeParcelas__c;
            obj.periodicidade = (Integer)item.Periodicidade__c;
            obj.inicioPagamento = (Integer)item.InicioPagamento__c;
            obj.tabelaVenda = tabelaId;
            obj.aposHabiteSe = item.AposHabiteSe__c;
    
            propostasConvertidas.add(obj);
        }

        List<SeriePagamentosService.ValorLinha> matrizMesaMesProposta = new List<SeriePagamentosService.ValorLinha>();
        List<SeriePagamentosService.ValorLinha> matrizMesaMesTabela =  new List<SeriePagamentosService.ValorLinha>();


       
        List<ComparacaoResultado> resultados = new List<ComparacaoResultado>();



        system.debug('valoresMatriz');
        system.debug(valoresMatriz); // Vazio
        
        system.debug('unidadeTabela');
        system.debug(unidadeTabelaVendaProduto); // Vazio
        
 //---------------------------------------------------------------------------------------------// 
        //1.Valor metro quadrado      
            ComparacaoResultado valorM2 = new ComparacaoResultado();
            valorM2.item = 'Valor do m²';
            valorM2.valorTabela = 0.0;
            valorM2.valorProposta = 0.0;

           if (
                tabelaVenda != null && 
                nominalTabela != null && 
                unidadeTabelaVendaProduto?.PrecoLista__c != null && 
                unidadeTabelaVendaProduto?.MetragemUnidade__c > 0.0
            ) {
                valorM2.valorTabela = nominalTabela / unidadeTabelaVendaProduto.MetragemUnidade__c;
            }

           if (
                unidadeTabelaVendaProduto?.MetragemUnidade__c > 0.0 && 
                (produtoSelecionado?.MetragemTotal__c != null || nominalProposta != null)
            ) {
                valorM2.valorProposta = nominalProposta / unidadeTabelaVendaProduto.MetragemUnidade__c;
           }

           
            if(valorM2.valorTabela > valorM2.valorProposta){
                valorM2.diferenca = valorM2.valorTabela - valorM2.valorProposta; 
            } else {
                valorM2.diferenca = valorM2.valorProposta - valorM2.valorTabela ; 
            }

           resultados.add(valorM2);
          

 //---------------------------------------------------------------------------------------------//    
        //2.% captação até metade do prazo       
            ComparacaoResultado captacaoAteMetadePrazo = new ComparacaoResultado();
            captacaoAteMetadePrazo.item = '% de Captação até metade do prazo';
            Decimal valorTotalMetadeSeriesTabela = 0.0;

            matrizMesaMesTabela = SeriePagamentosService.getListaGlobalTabela(tabelaId);

            for(Integer i = 0; i < matrizMesaMesTabela.size()/2; i++){
                valorTotalMetadeSeriesTabela += matrizMesaMesTabela[i].valorTotal;
            }

            captacaoAteMetadePrazo.valorTabela =  valorTotalMetadeSeriesTabela.setScale(2);
//--//

            Decimal valorTotalMetadeSeriesProposta = 0.0;

            matrizMesaMesProposta = SeriePagamentosService.getListaGlobalProposta(tabelaId, propostasConvertidas, nominalProposta);
        
            for(Integer i = 0; i < matrizMesaMesProposta.size()/2; i++){
                valorTotalMetadeSeriesProposta += matrizMesaMesProposta[i].valorTotal/100;
            }

            captacaoAteMetadePrazo.valorProposta =  valorTotalMetadeSeriesProposta.setScale(2);
            Decimal valorDiferencaMetadeMesAMes = null;

            if(captacaoAteMetadePrazo.valorProposta > captacaoAteMetadePrazo.valorTabela) {
                valorDiferencaMetadeMesAMes = captacaoAteMetadePrazo.valorProposta - captacaoAteMetadePrazo.valorTabela;
            } else {
                valorDiferencaMetadeMesAMes = captacaoAteMetadePrazo.valorTabela - captacaoAteMetadePrazo.valorProposta;
            }

            captacaoAteMetadePrazo.diferenca = valorDiferencaMetadeMesAMes.setScale(2); 
            resultados.add(captacaoAteMetadePrazo);

//---------------------------------------------------------------------------------------------//       
            // 3.Captação até habite-se
            ComparacaoResultado captacaoAteHabiteSe = new ComparacaoResultado();

            captacaoAteHabiteSe.item = '% de Captação até habite-se';

            Decimal valorTotalAteHabitaseTabela = 0.0;
            Decimal valorTotalAteHabitaseProposta = 0.0;
            Decimal valorDiferencaAteHabitase = null;

            matrizMesaMesTabela = SeriePagamentosService.getListaGlobalTabela(tabelaId);

            for(Integer i = 0; i < matrizMesaMesTabela.size(); i++){
                if(matrizMesaMesTabela[i].dataLinha  > empreendimentoProduto.DataHabitase__c){
                    break;
                }
                valorTotalAteHabitaseTabela += matrizMesaMesTabela[i].valorTotal;
            }

            captacaoAteHabiteSe.valorTabela = valorTotalAteHabitaseTabela.setScale(2);

            matrizMesaMesProposta = SeriePagamentosService.getListaGlobalProposta(tabelaId, propostasConvertidas, nominalProposta);
        
            for(Integer i = 0; i < matrizMesaMesProposta.size(); i++){
                if(matrizMesaMesProposta[i].dataLinha > empreendimentoProduto.DataHabitase__c){
                    break;
                }
                valorTotalAteHabitaseProposta += matrizMesaMesProposta[i].valorTotal/100;
            }

            captacaoAteHabiteSe.valorProposta = valorTotalAteHabitaseProposta.setScale(2);

            if(captacaoAteHabiteSe.valorProposta > captacaoAteHabiteSe.valorTabela) {
                valorDiferencaAteHabitase = captacaoAteHabiteSe.valorProposta - captacaoAteHabiteSe.valorTabela;
            } else {
                valorDiferencaAteHabitase = captacaoAteHabiteSe.valorTabela - captacaoAteHabiteSe.valorProposta;
            }
            
            captacaoAteHabiteSe.diferenca = valorDiferencaAteHabitase.setScale(2); 
            resultados.add(captacaoAteHabiteSe);


//---------------------------------------------------------------------------------------------//  
            // 4.Captação após habite-se
            ComparacaoResultado captacaoAposHabiteSe = new ComparacaoResultado();

            captacaoAposHabiteSe.item = '% de Captação após habite-se';

            Decimal valorTotalAposHabitaseTabela = 0.0;
            Decimal valorTotalAposHabitaseProposta = 0.0;
            Decimal valorDiferencaAposHabitase = null;

            matrizMesaMesTabela = SeriePagamentosService.getListaGlobalTabela(tabelaId);

            for(Integer i = 0; i < matrizMesaMesTabela.size(); i++){
                if(matrizMesaMesTabela[i].dataLinha  > empreendimentoProduto.DataHabitase__c){
                    valorTotalAposHabitaseTabela += matrizMesaMesTabela[i].valorTotal;
                }
            }

            captacaoAposHabiteSe.valorTabela = valorTotalAposHabitaseTabela.setScale(2);

            matrizMesaMesProposta = SeriePagamentosService.getListaGlobalProposta(tabelaId, propostasConvertidas, nominalProposta);

            for(Integer i = 0; i < matrizMesaMesProposta.size(); i++){
                if(matrizMesaMesProposta[i].dataLinha > empreendimentoProduto.DataHabitase__c){
                    valorTotalAposHabitaseProposta += matrizMesaMesProposta[i].valorTotal/100;
                }
            }

            captacaoAposHabiteSe.valorProposta = valorTotalAposHabitaseProposta.setScale(2);

            if(captacaoAposHabiteSe.valorProposta > captacaoAposHabiteSe.valorTabela) {
                valorDiferencaAposHabitase = captacaoAposHabiteSe.valorProposta - captacaoAposHabiteSe.valorTabela;
            } else {
                valorDiferencaAposHabitase = captacaoAposHabiteSe.valorTabela - captacaoAposHabiteSe.valorProposta;
            }

            captacaoAposHabiteSe.diferenca = valorDiferencaAposHabitase.setScale(2); 
            resultados.add(captacaoAposHabiteSe);
//---------------------------------------------------------------------------------------------//  
        // 5.Diferença
        ComparacaoResultado diferenca = new ComparacaoResultado();
        diferenca.item = 'Diferença';
        
        diferenca.valorProposta = nominalProposta;
        diferenca.valorTabela = nominalTabela;
        
        if(diferenca.valorProposta > diferenca.valorTabela){
            diferenca.diferenca = diferenca.valorProposta - diferenca.valorTabela;
        } else{
            diferenca.diferenca = diferenca.valorTabela - diferenca.valorProposta;
        }
        resultados.add(diferenca);
//---------------------------------------------------------------------------------------------//       


        return resultados;
    }
}