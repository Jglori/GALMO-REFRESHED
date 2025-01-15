@isTest
public class AdsInfoWrapperTest {

    @isTest
    public static void testAdsInfoWrapper() {
        AdsInfoWrapper adsInfo = new AdsInfoWrapper();
        
        adsInfo.category = 'Carro';
        adsInfo.subject = 'Carro à venda';
        adsInfo.body = 'Este é um anúncio de carro';
        adsInfo.type = 'À Venda';
        adsInfo.price = '20000';
        adsInfo.zipcode = '12345';
        adsInfo.regdate = '2025-01-01';
        adsInfo.mileage = '10000';
        adsInfo.carcolor = 'Vermelho';
        adsInfo.fuel = 'Gasolina';
        adsInfo.car_steering = 'Esquerda';
        adsInfo.exchange = 'Não';
        adsInfo.owner = 'Nome do Proprietário';
        adsInfo.financial = 'Financiado';
        adsInfo.financial_status = 'Aprovado';
        adsInfo.vehicle_brand = 'Marca X';
        adsInfo.vehicle_model = 'Modelo Y';
        adsInfo.vehicle_version = 'Versão 1';
        adsInfo.cubiccms = '2000';
        adsInfo.moto_features = 'ABS, Airbags';

        System.assertEquals('Carro', adsInfo.category);
        System.assertEquals('Carro à venda', adsInfo.subject);
        System.assertEquals('Este é um anúncio de carro', adsInfo.body);
        System.assertEquals('À Venda', adsInfo.type);
        System.assertEquals('20000', adsInfo.price);
        System.assertEquals('12345', adsInfo.zipcode);
        System.assertEquals('2025-01-01', adsInfo.regdate);
        System.assertEquals('10000', adsInfo.mileage);
        System.assertEquals('Vermelho', adsInfo.carcolor);
        System.assertEquals('Gasolina', adsInfo.fuel);
        System.assertEquals('Esquerda', adsInfo.car_steering);
        System.assertEquals('Não', adsInfo.exchange);
        System.assertEquals('Nome do Proprietário', adsInfo.owner);
        System.assertEquals('Financiado', adsInfo.financial);
        System.assertEquals('Aprovado', adsInfo.financial_status);
        System.assertEquals('Marca X', adsInfo.vehicle_brand);
        System.assertEquals('Modelo Y', adsInfo.vehicle_model);
        System.assertEquals('Versão 1', adsInfo.vehicle_version);
        System.assertEquals('2000', adsInfo.cubiccms);
        System.assertEquals('ABS, Airbags', adsInfo.moto_features);
    }
}