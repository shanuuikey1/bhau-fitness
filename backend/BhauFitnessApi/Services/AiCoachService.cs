using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using BhauFitnessApi.Models.DTOs;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace BhauFitnessApi.Services
{
    public class AiCoachService
    {
        private static readonly List<MotivationalTipDto> Tips = new()
        {
            new() { Tip = "Consistency beats intensity. 3 moderate workouts a week beats 1 extreme one.", Category = "Mindset" },
            new() { Tip = "Your body is a reflection of your lifestyle, not just your gym sessions.", Category = "Mindset" },
            new() { Tip = "Drink a glass of water immediately after waking up to kickstart your metabolism.", Category = "Hydration" },
            new() { Tip = "Progress isn't linear. Focus on how you feel, your energy, and your sleep quality.", Category = "Recovery" },
            new() { Tip = "Aim for 0.8g to 1g of protein per pound of body weight for muscle recovery.", Category = "Nutrition" },
            new() { Tip = "If you are tired, learn to rest, not to quit.", Category = "Mindset" },
            new() { Tip = "Active recovery like walking or light stretching increases blood flow and speeds up healing.", Category = "Recovery" },
            new() { Tip = "Sleep is where the magic happens. Aim for 7-8 hours of quality sleep.", Category = "Recovery" },
            new() { Tip = "Track your weights and reps. If you don't measure, you can't manage progress.", Category = "Training" },
            new() { Tip = "A 10-minute warm-up prevents injuries and increases muscle contraction efficiency.", Category = "Training" },
            new() { Tip = "Don't drink your calories. Swap sodas and juices for water and unsweetened tea.", Category = "Nutrition" },
            new() { Tip = "Fiber keeps you full and aids digestion. Eat more vegetables and whole grains.", Category = "Nutrition" },
            new() { Tip = "The only bad workout is the one that didn't happen.", Category = "Mindset" },
            new() { Tip = "Listen to your body. Sharp pain is a warning sign; muscle burn is growth.", Category = "Training" },
            new() { Tip = "Set performance goals, not just weight goals. Striving for a stronger lift is highly motivating.", Category = "Mindset" },
            new() { Tip = "Prepare your gym clothes the night before. Remove the friction of starting.", Category = "Mindset" },
            new() { Tip = "Carbohydrates are your body's primary fuel source. Don't fear them; time them around workouts.", Category = "Nutrition" },
            new() { Tip = "Stretching after a workout relaxes muscles and improves long-term range of motion.", Category = "Flexibility" },
            new() { Tip = "Small, daily habits compound into massive, life-changing results over a year.", Category = "Mindset" },
            new() { Tip = "Sweat is just fat crying. Keep pushing, Bhau!", Category = "Motivation" }
        };

        private readonly Random _random = new();
        private readonly HttpClient _httpClient;
        private readonly ILogger<AiCoachService> _logger;
        private readonly string _apiKey;

        public AiCoachService(HttpClient httpClient, IConfiguration configuration, ILogger<AiCoachService> logger)
        {
            _httpClient = httpClient;
            _logger = logger;
            _apiKey = configuration["Gemini:ApiKey"] ?? string.Empty;
        }

        public async Task<WorkoutPlanDto> GenerateWorkoutPlanAsync(string goal, double weightKg, string experienceLevel)
        {
            if (!string.IsNullOrEmpty(_apiKey))
            {
                try
                {
                    _logger.LogInformation("Calling Gemini API to generate workout plan...");
                    var prompt = $"Generate a 7-day workout plan for a person whose goal is {goal}, weight is {weightKg}kg, and experience level is {experienceLevel}. Respond ONLY in JSON matching this schema: {{ \"Goal\": \"...\", \"Duration\": \"7 Days\", \"Days\": [ {{ \"DayName\": \"Monday\", \"Focus\": \"...\", \"Exercises\": [ {{ \"Name\": \"...\", \"Sets\": 3, \"Reps\": 12, \"RestSeconds\": 60, \"Notes\": \"...\" }} ] }} ] }}";
                    var responseJson = await CallGeminiApiAsync(prompt);
                    var plan = JsonSerializer.Deserialize<WorkoutPlanDto>(responseJson, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                    if (plan != null && plan.Days != null && plan.Days.Count > 0)
                    {
                        return plan;
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to generate workout plan via Gemini. Falling back to rule-based generator.");
                }
            }

            // Fallback to rule-based generator
            return GenerateRuleBasedWorkoutPlan(goal, weightKg, experienceLevel);
        }

        public async Task<DietPlanDto> GenerateDietPlanAsync(string goal, double weightKg, double heightCm)
        {
            if (!string.IsNullOrEmpty(_apiKey))
            {
                try
                {
                    _logger.LogInformation("Calling Gemini API to generate diet plan...");
                    var prompt = $"Generate a personalized daily diet plan with meals for an Indian context for a person whose goal is {goal}, weight is {weightKg}kg, height is {heightCm}cm. Respond ONLY in JSON matching this schema: {{ \"Goal\": \"...\", \"DailyCalories\": 2000, \"DailyProteinG\": 150, \"DailyCarbsG\": 200, \"DailyFatG\": 60, \"Meals\": [ {{ \"MealType\": \"Breakfast\", \"Name\": \"...\", \"Description\": \"...\", \"Calories\": 500, \"ProteinG\": 40, \"CarbsG\": 50, \"FatG\": 15 }} ] }}";
                    var responseJson = await CallGeminiApiAsync(prompt);
                    var diet = JsonSerializer.Deserialize<DietPlanDto>(responseJson, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                    if (diet != null && diet.Meals != null && diet.Meals.Count > 0)
                    {
                        return diet;
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to generate diet plan via Gemini. Falling back to rule-based generator.");
                }
            }

            // Fallback to rule-based generator
            return GenerateRuleBasedDietPlan(goal, weightKg, heightCm);
        }

        public MotivationalTipDto GetMotivationalTip()
        {
            int index = _random.Next(Tips.Count);
            return Tips[index];
        }

        private async Task<string> CallGeminiApiAsync(string prompt)
        {
            var url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={_apiKey}";
            var payload = new
            {
                contents = new[]
                {
                    new { parts = new[] { new { text = prompt } } }
                },
                generationConfig = new
                {
                    responseMimeType = "application/json"
                }
            };

            var content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");
            var response = await _httpClient.PostAsync(url, content);
            response.EnsureSuccessStatusCode();

            var responseBody = await response.Content.ReadAsStringAsync();
            using var doc = JsonDocument.Parse(responseBody);
            var text = doc.RootElement
                .GetProperty("candidates")[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text")
                .GetString();

            return text ?? throw new InvalidOperationException("Gemini returned empty text.");
        }

        private WorkoutPlanDto GenerateRuleBasedWorkoutPlan(string goal, double weightKg, string experienceLevel)
        {
            var plan = new WorkoutPlanDto
            {
                Goal = goal,
                Duration = "7 Days"
            };

            int multiplier = experienceLevel.ToLower() switch
            {
                "advanced" => 4,
                "intermediate" => 3,
                _ => 2
            };

            if (goal.Equals("WeightLoss", StringComparison.OrdinalIgnoreCase))
            {
                plan.Days = GetWeightLossDays(multiplier);
            }
            else if (goal.Equals("MuscleGain", StringComparison.OrdinalIgnoreCase))
            {
                plan.Days = GetMuscleGainDays(multiplier);
            }
            else if (goal.Equals("Endurance", StringComparison.OrdinalIgnoreCase))
            {
                plan.Days = GetEnduranceDays(multiplier);
            }
            else
            {
                plan.Days = GetFlexibilityDays(multiplier);
            }

            return plan;
        }

        private DietPlanDto GenerateRuleBasedDietPlan(string goal, double weightKg, double heightCm)
        {
            double bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * 25) + 5;
            int tdee = (int)(bmr * 1.55);

            int targetCalories = goal.ToLower() switch
            {
                "weightloss" => tdee - 500,
                "musclegain" => tdee + 300,
                "endurance" => tdee,
                _ => tdee - 200
            };

            double proteinPct = goal.ToLower() == "musclegain" ? 0.30 : 0.25;
            double fatPct = 0.25;
            double carbPct = 1.0 - proteinPct - fatPct;

            int proteinG = (int)((targetCalories * proteinPct) / 4);
            int fatG = (int)((targetCalories * fatPct) / 9);
            int carbsG = (int)((targetCalories * carbPct) / 4);

            var diet = new DietPlanDto
            {
                Goal = goal,
                DailyCalories = targetCalories,
                DailyProteinG = proteinG,
                DailyCarbsG = carbsG,
                DailyFatG = fatG,
                Meals = GetMealsForGoal(goal.ToLower(), targetCalories, proteinG, carbsG, fatG)
            };

            return diet;
        }

        private List<DayPlan> GetWeightLossDays(int mult)
        {
            return new List<DayPlan>
            {
                new() {
                    DayName = "Monday", Focus = "Full Body Metabolic Circuit",
                    Exercises = new() {
                        new() { Name = "Goblet Squats", Sets = mult, Reps = 15, RestSeconds = 45, Notes = "Keep chest upright and core tight." },
                        new() { Name = "Dumbbell Thrusters", Sets = mult, Reps = 12, RestSeconds = 45, Notes = "Explosive press at the top." },
                        new() { Name = "Kettlebell Swings", Sets = mult, Reps = 20, RestSeconds = 30, Notes = "Hinge at hips, squeeze glutes." },
                        new() { Name = "Burpees", Sets = mult, Reps = 10, RestSeconds = 60, Notes = "Full push-up at bottom if possible." }
                    }
                },
                new() {
                    DayName = "Tuesday", Focus = "LISS Cardio & Core",
                    Exercises = new() {
                        new() { Name = "Treadmill Incline Walk", Sets = 1, Reps = 40, RestSeconds = 0, Notes = "Incline 8-10%, pace 5.0 km/h." },
                        new() { Name = "Hanging Leg Raises", Sets = 3, Reps = 12, RestSeconds = 45, Notes = "Avoid swinging, control descent." },
                        new() { Name = "Plank", Sets = 3, Reps = 60, RestSeconds = 45, Notes = "Squeeze glutes and keep back flat." }
                    }
                },
                new() {
                    DayName = "Wednesday", Focus = "Active Recovery",
                    Exercises = new() {
                        new() { Name = "Mobility Flow", Sets = 1, Reps = 20, RestSeconds = 0, Notes = "Light walking and deep yoga stretches." }
                    }
                },
                new() {
                    DayName = "Thursday", Focus = "Upper Body Conditioning",
                    Exercises = new() {
                        new() { Name = "Push-Ups", Sets = mult, Reps = 15, RestSeconds = 45, Notes = "Modify to knees if form breaks." },
                        new() { Name = "Dumbbell Renegade Rows", Sets = mult, Reps = 10, RestSeconds = 45, Notes = "Minimize hip rotation." },
                        new() { Name = "Mountain Climbers", Sets = mult, Reps = 30, RestSeconds = 30, Notes = "Keep shoulders over hands." }
                    }
                },
                new() {
                    DayName = "Friday", Focus = "Lower Body Burnout",
                    Exercises = new() {
                        new() { Name = "Walking Lunges", Sets = mult, Reps = 20, RestSeconds = 45, Notes = "10 reps per leg." },
                        new() { Name = "Romanian Deadlifts", Sets = mult, Reps = 12, RestSeconds = 60, Notes = "Feel stretch in hamstrings." },
                        new() { Name = "Jump Squats", Sets = mult, Reps = 15, RestSeconds = 45, Notes = "Soft landing on balls of feet." }
                    }
                },
                new() {
                    DayName = "Saturday", Focus = "HIIT Finisher",
                    Exercises = new() {
                        new() { Name = "Rowing Machine Sprint", Sets = 5, Reps = 200, RestSeconds = 60, Notes = "200m sprint, maximum effort." },
                        new() { Name = "Medicine Ball Slams", Sets = 3, Reps = 15, RestSeconds = 45, Notes = "Use full body power to slam." }
                    }
                },
                new() {
                    DayName = "Sunday", Focus = "Rest & Recharge",
                    Exercises = new() {
                        new() { Name = "Mindful Walk", Sets = 1, Reps = 30, RestSeconds = 0, Notes = "Easy outdoor walk." }
                    }
                }
            };
        }

        private List<DayPlan> GetMuscleGainDays(int mult)
        {
            return new List<DayPlan>
            {
                new() {
                    DayName = "Monday", Focus = "Push Day (Chest, Shoulders, Triceps)",
                    Exercises = new() {
                        new() { Name = "Incline Dumbbell Bench Press", Sets = mult, Reps = 8, RestSeconds = 90, Notes = "Focus on upper chest squeeze." },
                        new() { Name = "Overhead Press", Sets = mult, Reps = 8, RestSeconds = 90, Notes = "Full lock out at top." },
                        new() { Name = "Dumbbell Lateral Raises", Sets = 3, Reps = 12, RestSeconds = 60, Notes = "Slight forward lean." },
                        new() { Name = "Tricep Overhead Extension", Sets = 3, Reps = 10, RestSeconds = 60, Notes = "Keep elbows tucked." }
                    }
                },
                new() {
                    DayName = "Tuesday", Focus = "Pull Day (Back, Biceps)",
                    Exercises = new() {
                        new() { Name = "Pull-Ups or Lat Pulldowns", Sets = mult, Reps = 8, RestSeconds = 90, Notes = "Drive elbows down." },
                        new() { Name = "Barbell Rows", Sets = mult, Reps = 8, RestSeconds = 90, Notes = "Pull to lower stomach." },
                        new() { Name = "Face Pulls", Sets = 3, Reps = 15, RestSeconds = 60, Notes = "Target rear delts and rotator cuff." },
                        new() { Name = "Barbell Bicep Curls", Sets = 3, Reps = 10, RestSeconds = 60, Notes = "No body swing." }
                    }
                },
                new() {
                    DayName = "Wednesday", Focus = "Rest Day",
                    Exercises = new() {
                        new() { Name = "Active Recovery Stretch", Sets = 1, Reps = 15, RestSeconds = 0, Notes = "Focus on hips, shoulders, hamstrings." }
                    }
                },
                new() {
                    DayName = "Thursday", Focus = "Leg Day (Quads, Hamstrings, Calves)",
                    Exercises = new() {
                        new() { Name = "Barbell Back Squats", Sets = mult, Reps = 6, RestSeconds = 120, Notes = "Go to parallel or below." },
                        new() { Name = "Romanian Deadlifts", Sets = mult, Reps = 8, RestSeconds = 90, Notes = "Keep spine neutral." },
                        new() { Name = "Leg Extensions", Sets = 3, Reps = 12, RestSeconds = 60, Notes = "Hold squeeze at top for 1s." },
                        new() { Name = "Standing Calf Raises", Sets = 4, Reps = 15, RestSeconds = 60, Notes = "Full stretch at bottom." }
                    }
                },
                new() {
                    DayName = "Friday", Focus = "Upper Body Pump",
                    Exercises = new() {
                        new() { Name = "Dumbbell Flat Bench Press", Sets = mult, Reps = 10, RestSeconds = 75, Notes = "Control the eccentric phase." },
                        new() { Name = "Seated Cable Rows", Sets = mult, Reps = 10, RestSeconds = 75, Notes = "Squeeze shoulder blades." },
                        new() { Name = "Incline Bicep Curls", Sets = 3, Reps = 12, RestSeconds = 60, Notes = "Maximum stretch on biceps." },
                        new() { Name = "Cable Tricep Pushdowns", Sets = 3, Reps = 12, RestSeconds = 60, Notes = "Squeeze triceps at bottom." }
                    }
                },
                new() {
                    DayName = "Saturday", Focus = "Weak Point / Core",
                    Exercises = new() {
                        new() { Name = "Cable Woodchoppers", Sets = 3, Reps = 15, RestSeconds = 45, Notes = "Rotate torso, engage obliques." },
                        new() { Name = "Farmer Carries", Sets = 3, Reps = 40, RestSeconds = 60, Notes = "Heavy dumbbells, walk with upright posture." }
                    }
                },
                new() {
                    DayName = "Sunday", Focus = "Rest & Nutrition",
                    Exercises = new() {
                        new() { Name = "Meal Prep & Recovery", Sets = 1, Reps = 1, RestSeconds = 0, Notes = "Prioritize protein and sleep." }
                    }
                }
            };
        }

        private List<DayPlan> GetEnduranceDays(int mult)
        {
            return new List<DayPlan>
            {
                new() {
                    DayName = "Monday", Focus = "Interval Run",
                    Exercises = new() {
                        new() { Name = "Warm-up Jog", Sets = 1, Reps = 10, RestSeconds = 0, Notes = "10 mins easy jog." },
                        new() { Name = "High-Intensity Sprints", Sets = mult + 2, Reps = 1, RestSeconds = 90, Notes = "Sprint 400m at 90% effort." },
                        new() { Name = "Cool-down Walk", Sets = 1, Reps = 5, RestSeconds = 0, Notes = "5 mins light walk." }
                    }
                },
                new() {
                    DayName = "Tuesday", Focus = "Full Body Muscular Endurance",
                    Exercises = new() {
                        new() { Name = "Kettlebell Goblet Squats", Sets = 3, Reps = 25, RestSeconds = 30, Notes = "High reps, continuous movement." },
                        new() { Name = "Push-Ups", Sets = 3, Reps = 20, RestSeconds = 30, Notes = "Keep steady pace." },
                        new() { Name = "Single-Arm Dumbbell Rows", Sets = 3, Reps = 15, RestSeconds = 30, Notes = "15 reps per arm." }
                    }
                },
                new() {
                    DayName = "Wednesday", Focus = "Recovery Swim / Cycle",
                    Exercises = new() {
                        new() { Name = "Stationary Cycling", Sets = 1, Reps = 45, RestSeconds = 0, Notes = "Keep heart rate in Zone 2." }
                    }
                },
                new() {
                    DayName = "Thursday", Focus = "Tempo Run",
                    Exercises = new() {
                        new() { Name = "Tempo Running", Sets = 1, Reps = 25, RestSeconds = 0, Notes = "25 mins at hard but sustainable pace." }
                    }
                },
                new() {
                    DayName = "Friday", Focus = "Core & Stabilizers",
                    Exercises = new() {
                        new() { Name = "Bird Dog", Sets = 3, Reps = 15, RestSeconds = 30, Notes = "Alternate arms and legs." },
                        new() { Name = "Side Planks", Sets = 3, Reps = 45, RestSeconds = 30, Notes = "45s per side." }
                    }
                },
                new() {
                    DayName = "Saturday", Focus = "Long Slow Distance (LSD) Run",
                    Exercises = new() {
                        new() { Name = "Long Run", Sets = 1, Reps = 60 + (mult * 10), RestSeconds = 0, Notes = "Easy pace, conversational speed." }
                    }
                },
                new() {
                    DayName = "Sunday", Focus = "Rest Day",
                    Exercises = new() {
                        new() { Name = "Passive Rest", Sets = 1, Reps = 1, RestSeconds = 0, Notes = "Relax and stretch." }
                    }
                }
            };
        }

        private List<DayPlan> GetFlexibilityDays(int mult)
        {
            return new List<DayPlan>
            {
                new() {
                    DayName = "Monday", Focus = "Morning Vinyasa Yoga Flow",
                    Exercises = new() {
                        new() { Name = "Sun Salutations", Sets = 5, Reps = 1, RestSeconds = 15, Notes = "Synchronize breath with movement." },
                        new() { Name = "Warrior I & II Pose", Sets = 3, Reps = 5, RestSeconds = 15, Notes = "Hold each pose for 5 breaths." },
                        new() { Name = "Downward Facing Dog", Sets = 3, Reps = 30, RestSeconds = 15, Notes = "Pedal out feet to stretch calves." }
                    }
                },
                new() {
                    DayName = "Tuesday", Focus = "Hip & Hamstring Opening",
                    Exercises = new() {
                        new() { Name = "Pigeon Pose", Sets = 3, Reps = 60, RestSeconds = 15, Notes = "60s per side, breathe into hips." },
                        new() { Name = "Seated Forward Fold", Sets = 3, Reps = 45, RestSeconds = 15, Notes = "Keep back straight, hinge at hips." },
                        new() { Name = "Low Lunge with Quad Stretch", Sets = 3, Reps = 30, RestSeconds = 15, Notes = "30s per side." }
                    }
                },
                new() {
                    DayName = "Wednesday", Focus = "Active Recovery Stretch",
                    Exercises = new() {
                        new() { Name = "Full Body Joint Mobility", Sets = 1, Reps = 20, RestSeconds = 0, Notes = "Ankle, hip, wrist, shoulder circles." }
                    }
                },
                new() {
                    DayName = "Thursday", Focus = "Spine & Core Flexibility",
                    Exercises = new() {
                        new() { Name = "Cat-Cow Stretch", Sets = 3, Reps = 10, RestSeconds = 10, Notes = "Warm up spine." },
                        new() { Name = "Cobra Pose", Sets = 3, Reps = 30, RestSeconds = 15, Notes = "Open chest and stretch abs." },
                        new() { Name = "Child's Pose", Sets = 3, Reps = 60, RestSeconds = 0, Notes = "Decompress lower back." }
                    }
                },
                new() {
                    DayName = "Friday", Focus = "Shoulder & Upper Back Opening",
                    Exercises = new() {
                        new() { Name = "Thread the Needle", Sets = 3, Reps = 45, RestSeconds = 10, Notes = "45s per side, stretch upper back." },
                        new() { Name = "Puppy Pose", Sets = 3, Reps = 45, RestSeconds = 15, Notes = "Chest down, hips high." },
                        new() { Name = "Chest Opener Wall Stretch", Sets = 3, Reps = 30, RestSeconds = 10, Notes = "Stand near wall, stretch chest." }
                    }
                },
                new() {
                    DayName = "Saturday", Focus = "Yin Yoga (Deep Holds)",
                    Exercises = new() {
                        new() { Name = "Butterfly Pose", Sets = 1, Reps = 180, RestSeconds = 30, Notes = "Hold for 3 minutes, relax completely." },
                        new() { Name = "Sphinx Pose", Sets = 1, Reps = 120, RestSeconds = 30, Notes = "Hold for 2 minutes on elbows." }
                    }
                },
                new() {
                    DayName = "Sunday", Focus = "Rest & Meditate",
                    Exercises = new() {
                        new() { Name = "Savasana (Corpse Pose)", Sets = 1, Reps = 10, RestSeconds = 0, Notes = "10 minutes quiet breathing." }
                    }
                }
            };
        }

        private List<MealItem> GetMealsForGoal(string goal, int cals, int prot, int carbs, int fat)
        {
            var meals = new List<MealItem>();

            if (goal == "musclegain")
            {
                meals.Add(new() {
                    MealType = "Breakfast", Name = "Mass Gainer Oatmeal",
                    Description = "Oats (80g) cooked in double-toned milk, 1 scoop whey protein, 1 banana, 15g almonds, 1 tbsp peanut butter.",
                    Calories = (int)(cals * 0.28), ProteinG = (int)(prot * 0.32), CarbsG = (int)(carbs * 0.28), FatG = (int)(fat * 0.25)
                });
                meals.Add(new() {
                    MealType = "Snack 1", Name = "Egg & Toast",
                    Description = "3 whole boiled eggs with 2 slices of whole wheat toast.",
                    Calories = (int)(cals * 0.12), ProteinG = (int)(prot * 0.15), CarbsG = (int)(carbs * 0.08), FatG = (int)(fat * 0.15)
                });
                meals.Add(new() {
                    MealType = "Lunch", Name = "Chicken Rice Bowl",
                    Description = "Grilled chicken breast (200g), basmati rice (150g cooked), mixed stir-fry vegetables, 1 tsp olive oil.",
                    Calories = (int)(cals * 0.35), ProteinG = (int)(prot * 0.35), CarbsG = (int)(carbs * 0.38), FatG = (int)(fat * 0.30)
                });
                meals.Add(new() {
                    MealType = "Snack 2", Name = "Paneer & Fruit",
                    Description = "Low-fat paneer (100g) with 1 apple.",
                    Calories = (int)(cals * 0.10), ProteinG = (int)(prot * 0.10), CarbsG = (int)(carbs * 0.10), FatG = (int)(fat * 0.10)
                });
                meals.Add(new() {
                    MealType = "Dinner", Name = "Fish & Sweet Potato",
                    Description = "Baked Rohu/Salmon (150g), baked sweet potato (150g), steamed broccoli.",
                    Calories = (int)(cals * 0.15), ProteinG = (int)(prot * 0.08), CarbsG = (int)(carbs * 0.16), FatG = (int)(fat * 0.20)
                });
            }
            else if (goal == "weightloss")
            {
                meals.Add(new() {
                    MealType = "Breakfast", Name = "High Protein Oats & Berries",
                    Description = "Oats (40g) cooked in water, 1 scoop whey protein isolate, 50g blueberries, 5 almonds.",
                    Calories = (int)(cals * 0.25), ProteinG = (int)(prot * 0.30), CarbsG = (int)(carbs * 0.25), FatG = (int)(fat * 0.20)
                });
                meals.Add(new() {
                    MealType = "Snack 1", Name = "Boiled Egg Whites",
                    Description = "4 boiled egg whites with cucumber slices.",
                    Calories = (int)(cals * 0.10), ProteinG = (int)(prot * 0.15), CarbsG = (int)(carbs * 0.05), FatG = (int)(fat * 0.05)
                });
                meals.Add(new() {
                    MealType = "Lunch", Name = "Lean Paneer Salad Bowl",
                    Description = "Low-fat paneer (150g) or Grilled Tofu, big green salad (lettuce, cucumber, bell peppers, tomatoes) with lemon dressing, 50g brown rice.",
                    Calories = (int)(cals * 0.35), ProteinG = (int)(prot * 0.32), CarbsG = (int)(carbs * 0.35), FatG = (int)(fat * 0.35)
                });
                meals.Add(new() {
                    MealType = "Snack 2", Name = "Greek Yogurt",
                    Description = "Unsweetened Greek Yogurt (150g) with a dash of cinnamon.",
                    Calories = (int)(cals * 0.10), ProteinG = (int)(prot * 0.13), CarbsG = (int)(carbs * 0.08), FatG = (int)(fat * 0.10)
                });
                meals.Add(new() {
                    MealType = "Dinner", Name = "Grilled Chicken Salad",
                    Description = "Sautéed chicken breast (150g) with mixed vegetables (zucchini, broccoli, mushrooms) in 1 tsp olive oil.",
                    Calories = (int)(cals * 0.20), ProteinG = (int)(prot * 0.10), CarbsG = (int)(carbs * 0.27), FatG = (int)(fat * 0.30)
                });
            }
            else
            {
                meals.Add(new() {
                    MealType = "Breakfast", Name = "Banana Peanut Butter Toast",
                    Description = "2 slices of whole wheat toast, 1.5 tbsp peanut butter, 1 sliced banana, 2 boiled eggs.",
                    Calories = (int)(cals * 0.25), ProteinG = (int)(prot * 0.25), CarbsG = (int)(carbs * 0.25), FatG = (int)(fat * 0.25)
                });
                meals.Add(new() {
                    MealType = "Snack 1", Name = "Mixed Nuts & Orange",
                    Description = "30g mixed raw nuts (almonds, walnuts) and 1 orange.",
                    Calories = (int)(cals * 0.10), ProteinG = (int)(prot * 0.08), CarbsG = (int)(carbs * 0.12), FatG = (int)(fat * 0.15)
                });
                meals.Add(new() {
                    MealType = "Lunch", Name = "Indian Balanced Thali",
                    Description = "2 whole wheat rotis, 1 cup dal, 1 cup mixed vegetable sabzi, 100g chicken breast or paneer, 1 cup curd.",
                    Calories = (int)(cals * 0.35), ProteinG = (int)(prot * 0.38), CarbsG = (int)(carbs * 0.35), FatG = (int)(fat * 0.30)
                });
                meals.Add(new() {
                    MealType = "Snack 2", Name = "Sprouted Moong Salad",
                    Description = "1 cup sprouted moong, chopped onions, tomatoes, coriander, lemon juice.",
                    Calories = (int)(cals * 0.10), ProteinG = (int)(prot * 0.12), CarbsG = (int)(carbs * 0.10), FatG = (int)(fat * 0.05)
                });
                meals.Add(new() {
                    MealType = "Dinner", Name = "Soya Chunks & Quinoa",
                    Description = "Soya chunks (60g cooked), 100g cooked quinoa, steamed spinach.",
                    Calories = (int)(cals * 0.20), ProteinG = (int)(prot * 0.17), CarbsG = (int)(carbs * 0.18), FatG = (int)(fat * 0.25)
                });
            }

            return meals;
        }
    }
}
