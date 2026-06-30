namespace BhauFitnessApi.Models.Entities;

public interface IMultitenant
{
    string TenantId { get; set; }
}
