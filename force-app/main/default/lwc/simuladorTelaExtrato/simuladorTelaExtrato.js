import { LightningElement, api } from 'lwc';

export default class SimuladorTelaExtrato extends LightningElement {
    @api propostasClienteData;
    @api idTabelaVendas;
    @api valoresMatriz;
    @api produtoSelecionado;

    valoresMatrizProposta;


    get getValoresMatrizProposta(){
        return this.valoresMatrizProposta;
    }

    get getProdutoSelecionado(){
        return this.produtoSelecionado;
    }

    connectedCallback(){
        if(!this.valoresMatriz) {return;}

        console.log('simuladorTelaEsxtrato: '+ JSON.stringify(this.getProdutoSelecionado))
        console.log('valores matriz: '+ JSON.stringify(this.valoresMatriz))

        this.valoresMatrizProposta = {
                                      nominalProposta: this.valoresMatriz.nominalProposta,
                                      vplProposta: this.valoresMatriz.valorVplProposta,
                                      nominalTabela: this.valoresMatriz.nominalTabela,
                                      valorVplTabela: this.valoresMatriz.valorVplTabela
                                     }
        
        console.log('DEBUG', JSON.stringify(this.valoresMatrizProposta));
    }

}