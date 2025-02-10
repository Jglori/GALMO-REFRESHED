public with sharing class EmpreendimentoHelper {

    public static Boolean validarCNPJ(String cnpj) {
        // Se for nulo ou vazio, retorna falso
        if (String.isBlank(cnpj)) {
            return false;
        }

        // Remove caracteres não numéricos
        cnpj = cnpj.replaceAll('[^0-9]', '');

        // Valida o tamanho do CNPJ
        if (cnpj.length() != 14) {
            return false;
        }

        // Verifica se é um CNPJ inválido com todos os números iguais
        if (cnpj == '00000000000000' || cnpj == '11111111111111' || cnpj == '22222222222222' ||
            cnpj == '33333333333333' || cnpj == '44444444444444' || cnpj == '55555555555555' ||
            cnpj == '66666666666666' || cnpj == '77777777777777' || cnpj == '88888888888888' ||
            cnpj == '99999999999999') {
            return false;
        }

        // Cálculo do primeiro dígito verificador
        Integer[] multiplicadores1 = new Integer[] {5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
        Integer soma = 0;
        for (Integer i = 0; i < 12; i++) {
            soma += Integer.valueOf(cnpj.substring(i, i+1)) * multiplicadores1[i];
        }
        Integer primeiroDigito = 11 - Math.mod(soma, 11);
        if (primeiroDigito >= 10) {
            primeiroDigito = 0;
        }

        if (primeiroDigito != Integer.valueOf(cnpj.substring(12, 13))) {
            return false;
        }

        // Cálculo do segundo dígito verificador
        Integer[] multiplicadores2 = new Integer[] {6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2};
        soma = 0;
        for (Integer i = 0; i < 13; i++) {
            soma += Integer.valueOf(cnpj.substring(i, i+1)) * multiplicadores2[i];
        }
        Integer segundoDigito = 11 - Math.mod(soma, 11);
        if (segundoDigito >= 10) {
            segundoDigito = 0;
        }

        if (segundoDigito != Integer.valueOf(cnpj.substring(13, 14))) {
            return false;
        }

        return true;
    }
}