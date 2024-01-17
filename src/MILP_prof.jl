using JuMP
using GLPK
using JSON


include("utils.jl")
include("instance.jl")
include("solution.jl")
include("parsing.jl")
include("eval.jl")

export Instance, Solution
export read_instance, read_solution, write_solution
export construction_cost, operational_cost, cost
export is_feasible


# Fonction pour créer et résoudre le modèle
function solve_optimization(instance::Instance)
    model = Model(optimizer_with_attributes(GLPK.Optimizer))

    # Variables de décision
    @variable(model, turbines[1:nb_turbines(instance)], Bin)  # Variables binaires pour les turbines
    @variable(model, cables[1:nb_station_locations(instance), 1:nb_station_locations(instance)], Bin)  # Variables binaires pour les câbles inter-stations
    @variable(model, substations[1:nb_station_locations(instance)], Bin)  # Variables binaires pour les sous-stations

    # Fonction objectif
    @objective(model, Min, cost(Solution(turbines, cables, substations), instance))

    # Contraintes
    @constraint(model, is_feasible(Solution(turbines, cables, substations), instance) == true)

    # Résoudre le modèle
    optimize!(model)

    # Récupérer la solution optimale
    optimal_turbines = value.(turbines)
    optimal_cables = value.(cables)
    optimal_substations = value.(substations)

    optimal_solution = Solution(optimal_turbines, optimal_cables, optimal_substations)

    # Afficher la solution optimale
    println("Optimal Solution: ", optimal_solution)
    println("Objective Value: ", objective_value(model))
end

# Appeler la fonction pour résoudre le problème d'optimisation

instance = read_instance("instances/KIRO-small.json")
solve_optimization(instance)