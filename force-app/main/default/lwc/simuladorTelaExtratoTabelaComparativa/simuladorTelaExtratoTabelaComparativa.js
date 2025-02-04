import { LightningElement, api, track, wire } from 'lwc';
import calcularComparacao from '@salesforce/apex/ComparativoController.calcularComparacao';
import obterSeriesPorIdTabela from '@salesforce/apex/SimuladorTelaNegociacaoController.obterSeriesPorIdTabela';
import {calcularDiferencaMeses} from 'c/utils';

const colunas = [
    { label: 'Item', fieldName: 'item' }, 
    { label: 'Tabela', fieldName: 'valorTabela', type: 'text' }, 
    { label: 'Proposta', fieldName: 'valorProposta', type: 'text' },
    { label: 'Diferença', fieldName: 'diferenca', type: 'text' } 
];

const periodicidades = [
    {tipoCondicao: 'Ato', periodicidade: 1}, 
    {tipoCondicao: 'Mensais', periodicidade: 1}, 
    {tipoCondicao: 'Sinal', periodicidade: 1}, 
    {tipoCondicao: 'Única', periodicidade: 1}, 
    {tipoCondicao: 'Financiamento', periodicidade: 1}, 
    {tipoCondicao: 'Periódica', periodicidade: 1}, 
    {tipoCondicao: 'Bimestral', periodicidade: 2}, 
    {tipoCondicao: 'Trimestral', periodicidade: 3}, 
    {tipoCondicao: 'Semestrais', periodicidade: 6}, 
    {tipoCondicao: 'Anuais', periodicidade: 12}
];


export default class SimuladorTelaExtratoTabelaComparativa extends LightningElement {
    @api propostasCliente = [];
    @track propostasClienteFormatada = [];
    @track seriesPagamentoTabela = [];

    @api idTabelaVenda;

    @api valoresMatriz;

    @api produtoSelecionado;


    @track comparacaoResultados = [];
    @track colunas = colunas;

    @track mesAmesTabela = [];
    @track mesAmesProposta = [];

    connectedCallback() {
        console.log('connectedCallback executed');
        console.log('PropostasCliente:', JSON.stringify(this.propostasCliente)); 
        console.log('IdTabelaVenda:', this.idTabelaVenda);
        console.log('valoresMatrizComparativa:', JSON.stringify(this.valoresMatriz));
        console.log('produto selecionado', JSON.stringify(this.produtoSelecionado));

       this.calcularPeriodicidade();
       this.carregarComparacao();
    }

    get getProdutoSelecionados(){
        return this.produtoSelecionado;
    }



    calcularPeriodicidade(){
        let SeriesPagamento__c = [];
        console.log('testeando');
        console.log(JSON.stringify(this.propostasCliente));

        this.propostasCliente.forEach(serie => {
            let periodicidadeSerie = serie.TipoCondicao__c ? periodicidades.find(tipoCondicao => tipoCondicao.tipoCondicao === serie.TipoCondicao__c) : null;
           
            console.log(JSON.stringify(periodicidadeSerie))

            SeriesPagamento__c.push({
                TipoCondicao__c: serie.TipoCondicao__c,
                InicioPagamento__c: calcularDiferencaMeses(serie.InicioPagamento__c),
                QuantidadeParcelas__c: serie.QuantidadeParcelas__c,
                ValorTotal__c: serie.ValorTotal__c,
                AposHabiteSe__c: serie.AposHabiteSe__c,
                TabelaVenda__c: null,
                DiaDeVencimento__c: serie.vencimentoParcela,
                Periodicidade__c: periodicidadeSerie.periodicidade
            })
        });

        this.propostasClienteFormatada = SeriesPagamento__c;
    }
    


    carregarComparacao() {
        console.log('sociojklmsdfgjiklosdgfkijldfgskmlsedfgkml');
        console.log(JSON.stringify(this.propostasClienteFormatada));

        if (this.propostasCliente && this.idTabelaVenda) {
            var produtoSelecionadoSerializado = JSON.stringify(this.produtoSelecionado);

            calcularComparacao({ tabelaId: this.idTabelaVenda, proposta: this.propostasClienteFormatada, valoresMatriz: this.valoresMatriz, produto: produtoSelecionadoSerializado})
                .then(result => {
                    console.log('Apex Result:', result); 
                    
                    this.comparacaoResultados = result.map(item => {
                        console.log('Mapping Item:', item); 

                        const mappedItem = {
                            item: item.item,
                            valorTabela: this.formatValue(item.valorTabela, item.item),
                            valorProposta: this.formatValue(item.valorProposta, item.item),
                            diferenca: this.formatValue(item.diferenca, item.item)
                        };

                        console.log('Mapped Item:', mappedItem); 
                        return mappedItem;
                    });

                    console.log('Mapped Results:', this.comparacaoResultados); 
                })
                .catch(error => {
                    console.error('Hata: ', error);
                });
        } else {
            console.error('PropostasCliente ou idTabelaVenda nao existe');
        }
    }



  
    

    
    formatValue(value, item) {
        
        const percentageItems = [
            '% de Captação até habite-se', 
            '% de Captação até metade do prazo',
            '% de Captação após habite-se'
        ];

        if (percentageItems.includes(item)) {
            return this.formatPercentage(value);
        } else {
            return this.formatCurrency(value);
        }
    }

    formatCurrency(value) {
        return new Intl.NumberFormat('pt-BR', { 
            style: 'currency', 
            currency: 'BRL', 
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2 
        }).format(value);
    }

    formatPercentage(value) {
        return new Intl.NumberFormat('pt-BR', { 
            style: 'percent', 
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2 
        }).format(value / 100);
    }
}