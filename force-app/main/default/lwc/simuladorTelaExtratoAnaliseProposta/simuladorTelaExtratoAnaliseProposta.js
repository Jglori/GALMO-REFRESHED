import analisarProposta from '@salesforce/apex/comissaoController.analisarProposta';
import getCriteriosById from '@salesforce/apex/ParametrizarCriteriosController.getConjuntoCriteriosAnaliseById';
import { LightningElement, api, track } from 'lwc';

const analiseColunasOptions = [
    { label: 'Critério', fieldName: 'criterio' },
    { label: 'Tabela', fieldName: 'formattedValorTabela', type: 'text' }, 
    { label: 'Proposta', fieldName: 'formattedValorProposta', type: 'text' }, 
    { label: 'Limite', fieldName: 'dentroDoLimite', type: 'boolean' }
];

export default class SimuladorTelaExtratoAnaliseProposta extends LightningElement {
    analiseColunasOptions = analiseColunasOptions;
    @api propostasCliente;
    @api idTabelaVenda;
    @api valoresMatriz;

    @track analisePropostasCliente = [];
    @track conjuntoCriterio;

    criteriosFilter = {
        criteria: [
            {
                fieldPath: 'Ativo__c',
                operator: 'eq',
                value: true
            }
        ]
    };

    get getNominalProposta(){
        return parseFloat(this.valoresMatriz.nominalProposta)
    }

    get getValorVplProposta(){
        return parseFloat(this.valoresMatriz.valorVplProposta)
    }

    get getNominalTabela(){
        return parseFloat(this.valoresMatriz.nominalTabela)
    }

    get getValorVplTabela(){
        return parseFloat(this.valoresMatriz.valorVplTabela)
    }

    get getValoresMatriz(){
        return {nominalProposta: this.getNominalProposta,
                nominalTabela: this.getNominalTabela,
                valorVplProposta: this.getValorVplProposta,
                valorVplTabela: this.getValorVplTabela}
    }


    formatValor(valor) {
        return `R$${valor.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
    }

    analisarPropostaCliente() {
        analisarProposta({ tabelaId: this.idTabelaVenda, proposta: this.propostasCliente, valoresMatriz: this.valoresMatriz, conjuntoCriterios: this.conjuntoCriterio })
            .then(result => {
                console.log('result:: ');
                console.log(result);
                
                this.analisePropostasCliente = result.map(item => {
                    return {
                        ...item,
                        formattedValorTabela: this.formatValue(item.valorTabela, item.criterio),  
                        formattedValorProposta: this.formatValue(item.valorProposta, item.criterio)  
                    };
                });
            })
            .catch(error => {
                console.error('Erro ao analisar proposta:', error);
            });
    }

    formatValue(value, criterio) {
        
        const percentageCriteria = [
            '% de Captação à vista',
            '% de Captação até habita-se',
            '% de Captação mensal'
            
        ];

        const numericOnlyCriteria = [
            'Prazo de financiamento'
        ];

        if (percentageCriteria.includes(criterio)) {
            return this.formatPercentage(value);
        } else if (numericOnlyCriteria.includes(criterio)) {
            return value; 
        } else {
            return this.formatCurrency(value);
        }
    }
    

    formatCurrency(value) {
        if (value == null || isNaN(value)) {
            return value;
        }
        return new Intl.NumberFormat('pt-BR', { 
            style: 'currency', 
            currency: 'BRL', 
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2 
        }).format(value);
    }

    formatPercentage(value) {
        if (value == null || isNaN(value)) {
            return value;
        }
        return new Intl.NumberFormat('pt-BR', { 
            style: 'percent', 
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2 
        }).format(value / 100);
    }

    async handleCriterios(event) {
        const conjuntoCriterioId = event.detail.recordId;
        
        this.conjuntoCriterio = conjuntoCriterioId;

        if(conjuntoCriterioId === null){
            this.blocoOptions = [];
        }
        try {
            await this.getCriterios();
            this.analisarPropostaCliente();
        } catch (error) {
            console.error('Error: '+ error);
        }
    }

    async getCriterios() {        
        try {
            const result = await getCriteriosById({ id: this.conjuntoCriterio })
            this.conjuntoCriterio = result;
        } catch (error) {
            console.error('Error: '+error);
            new this.dispatchEvent()
        }
    }
}