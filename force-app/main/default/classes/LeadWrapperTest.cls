@isTest
public class LeadWrapperTest {

    @isTest
    public static void testLeadWrapper() {
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
        adsInfo.owner = 'Nome do proprietário';
        adsInfo.financial = 'Financiado';
        adsInfo.financial_status = 'Aprovado';
        adsInfo.vehicle_brand = 'Marca X';
        adsInfo.vehicle_model = 'Modelo Y';
        adsInfo.vehicle_version = 'Versão 1';
        adsInfo.cubiccms = '2000';
        adsInfo.moto_features = 'ABS, Airbags';

        LeadWrapper lead = new LeadWrapper();
        lead.source = 'Website';
        lead.adId = '12345';
        lead.listId = '67890';
        lead.CanalAtendimento = 'Telefone';
        lead.mobilePhone = '1234567890';
        lead.tipoRegistro = 'Novo';
        lead.linkAd = 'http://exemplo.com/anuncio';
        lead.name = 'João Silva';
        lead.email = 'joaosilva@exemplo.com';
        lead.phone = '0987654321';
        lead.message = 'Interessado no carro';
        lead.createdAt = '2025-01-01';
        lead.adsInfo = adsInfo;
        lead.externalId = 'externo123';

        System.assertEquals('Website', lead.source);
        System.assertEquals('12345', lead.adId);
        System.assertEquals('67890', lead.listId);
        System.assertEquals('Telefone', lead.CanalAtendimento);
        System.assertEquals('1234567890', lead.mobilePhone);
        System.assertEquals('Novo', lead.tipoRegistro);
        System.assertEquals('http://exemplo.com/anuncio', lead.linkAd);
        System.assertEquals('João Silva', lead.name);
        System.assertEquals('joaosilva@exemplo.com', lead.email);
        System.assertEquals('0987654321', lead.phone);
        System.assertEquals('Interessado no carro', lead.message);
        System.assertEquals('2025-01-01', lead.createdAt);
        System.assertEquals('externo123', lead.externalId);
    }
}