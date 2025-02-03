const fs = require('fs');
const { XMLParser } = require('fast-xml-parser');
const { exec } = require('child_process');

// Caminho para o arquivo package.xml
const packageXmlPath = 'manifest/package.xml';

// Função para extrair classes de teste que terminam com 'Test'
const extractTestClasses = (xmlData) => {
  const testClasses = [];

  // Verifica se há testes no arquivo XML
  const packageObject = xmlData.Package;
  if (packageObject && packageObject.types) {
    packageObject.types.forEach(type => {
      if (type.name === 'ApexClass') {
        // Filtra as classes que terminam com 'Test'
        type.members.forEach(member => {
          console.log(`Verificando classe: ${member}`); // Log para depuração
          if (member.match(/Test$/)) {  // Classe que termina com 'Test'
            testClasses.push(member);
          }
        });
      }
    });
  }

  return testClasses;
};

// Função para rodar o deploy com as classes de teste extraídas
const deployWithTests = (testClasses) => {
  if (testClasses.length === 0) {
    console.log('Nenhuma classe de teste encontrada.');
    return;
  }

  // Converte as classes de teste em uma string separada por vírgulas
  const testsStr = testClasses.join(',');
  console.log(`Rodando deploy com as classes de teste: ${testsStr}`);

  // Comando para rodar o deploy usando o Salesforce CLI
  exec(`sf project deploy start --test-level RunSpecifiedTests --tests ${testsStr} -x ${packageXmlPath}`, (error, stdout, stderr) => {
    if (error) {
      console.error(`Erro ao executar o deploy: ${error.message}`);
      return;
    }
    if (stderr) {
      console.error(`stderr: ${stderr}`);
      return;
    }
    console.log(`stdout: ${stdout}`);
  });
};

// Função principal para carregar o XML e iniciar o processo
const main = () => {
  // Lê o conteúdo do arquivo package.xml
  fs.readFile(packageXmlPath, 'utf8', (err, data) => {
    if (err) {
      console.error('Erro ao ler o arquivo package.xml:', err);
      return;
    }

    // Configura o parser para ignorar o namespace
    const parser = new XMLParser({
      ignoreAttributes: true,  // Ignorar atributos do namespace
      parseNodeValue: true,  // Garantir que o valor dos nós seja lido corretamente
    });

    // Parseia o XML para um objeto JavaScript
    const result = parser.parse(data);

    // Extrai as classes de teste
    const testClasses = extractTestClasses(result);

    // Executa o deploy com as classes extraídas
    deployWithTests(testClasses);
  });
};

// Executa o script
main();
