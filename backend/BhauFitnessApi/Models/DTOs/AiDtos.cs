using System.Collections.Generic;

namespace BhauFitnessApi.Models.DTOs
{
    public class AiRequestDto
    {
        public string Goal { get; set; } = string.Empty; // WeightLoss, MuscleGain, Endurance, Flexibility
        public double WeightKg { get; set; }
        public double HeightCm { get; set; }
        public string ExperienceLevel { get; set; } = string.Empty; // Beginner, Intermediate, Advanced
    }

    public class WorkoutPlanDto
    {
        public string Goal { get; set; } = string.Empty;
        public string Duration { get; set; } = string.Empty;
        public List<DayPlan> Days { get; set; } = new();
    }

    public class DayPlan
    {
        public string DayName { get; set; } = string.Empty;
        public string Focus { get; set; } = string.Empty;
        public List<ExerciseItem> Exercises { get; set; } = new();
    }

    public class ExerciseItem
    {
        public string Name { get; set; } = string.Empty;
        public int Sets { get; set; }
        public int Reps { get; set; }
        public int RestSeconds { get; set; }
        public string Notes { get; set; } = string.Empty;
    }

    public class DietPlanDto
    {
        public string Goal { get; set; } = string.Empty;
        public int DailyCalories { get; set; }
        public int DailyProteinG { get; set; }
        public int DailyCarbsG { get; set; }
        public int DailyFatG { get; set; }
        public List<MealItem> Meals { get; set; } = new();
    }

    public class MealItem
    {
        public string MealType { get; set; } = string.Empty; // Breakfast, Snack1, Lunch, Snack2, Dinner
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public int Calories { get; set; }
        public int ProteinG { get; set; }
        public int CarbsG { get; set; }
        public int FatG { get; set; }
    }

    public class MotivationalTipDto
    {
        public string Tip { get; set; } = string.Empty;
        public string Category { get; set; } = string.Empty;
    }
}
