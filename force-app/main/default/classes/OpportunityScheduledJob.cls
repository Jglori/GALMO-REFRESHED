public class OpportunityScheduledJob implements Schedulable, Queueable {
    
    // Método necessário para a interface Schedulable (agendamento de jobs)
    // Este método será chamado quando o job for agendado para execução
    public void execute(SchedulableContext context) {
        // Lógica comentada, não executa nada
        // System.debug('Job de oportunidades agendado');
    }
    
    // Método necessário para a interface Queueable (enfileiramento de jobs)
    // Este método será chamado quando o job for enfileirado para execução
    public void execute(QueueableContext context) {
        // Lógica comentada, não executa nada
        // System.debug('Job de oportunidades enfileirado');
    }
}