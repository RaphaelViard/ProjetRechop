import .KIRO2023
using Plots
using JSON

include("Algorithm.jl")

chemin_tiny = "instances/KIRO-tiny.json"
chemin_small = "instances/KIRO-small.json"
chemin_medium = "instances/KIRO-medium.json"
chemin_large = "instances/KIRO-large.json"
chemin_huge = "instances/KIRO-huge.json"

#---------------------------------VARIABLES UTILES------------------------------------------------------------------------------

current_instance = KIRO2023.read_instance(chemin_tiny)

nb_WT = length(current_instance.wind_turbines) #Nombre de wind_turbine dans notre instance
nb_SS = length(current_instance.substation_locations) #Nombre de substation dans notre instance
CardVS=nb_SS
CardE0=CardVS
CardVT=nb_WT
CardS = length(current_instance.substation_types) #Card(S)
CardE0=nb_WT
CardQ0=length(current_instance.land_substation_cable_types)
CardES= CardVS*(CardVS-1)
CardQS=length(current_instance.substation_substation_cable_types)
CardET=CardVT*CardVS
OMEGA = length(current_instance.wind_scenarios)

#-------------------------------------------------------------------------------------------------------------------------------


#---------------------------------INITIALISATION------------------------------------------------------------------------------

turbine_links1=[1,1,1]
inter_station_cables1 = zeros(Int,2,2)
substations1 = [KIRO2023.SubStation(1,1,1)]

Heuristique_prime = KIRO2023.Solution(turbine_links1,inter_station_cables1,substations1)

# On obtient un cout total de 200 000 avec une première heuristique d'initialisation paramétrée à la main.

# La solution optimale aura un cout total inférieur à 200 000. 
# Comme, la station la moins chère coute 100 000, alors la solution optimale comportera une unique sous station.

#-------------------------------------------------------------------------------------------------------------------------------



# Pour le tiny_set, on peut se permettre de décrire toutes les solutions possibles (une station construite)

# On fait varier les types de sous station, de land_cables.

function solutions_with_one_substation_built(instance::KIRO2023.Instance)
# 1 station construite
    P = Vector{KIRO2023.Solution}()
    for i in 1:nb_SS
        for j in 1:CardS
            for k in 1:CardQ0
                substations = [KIRO2023.SubStation(i, j, k)]
                inter_station_cables = zeros(Int, 2, 2)
                turbine_links=[i,i,i]
                push!(P,KIRO2023.Solution(turbine_links,inter_station_cables,substations))
            end
        end
    end
    return P
end


function find_min(P::Vector{KIRO2023.Solution},instance::KIRO2023.Instance)
    a=KIRO2023.Solution(turbine_links1,inter_station_cables1,substations1)
    for sol in P
        if KIRO2023.cost(sol, current_instance) < KIRO2023.cost(a,current_instance) 
            a = sol
        end
    end
    return a
end

println(KIRO2023.is_feasible(Heuristique_prime,current_instance))
a1 = KIRO2023.cost(Heuristique_prime,current_instance)
println("Le cout de la premiere heuristique est $a1")
d1 = KIRO2023.operational_cost(Heuristique_prime,current_instance)
e1 = KIRO2023.construction_cost(Heuristique_prime,current_instance)
println("Cout operationnel : $d1, cout de construction : $e1")


b = find_min(solutions_with_one_substation_built(current_instance),current_instance)

println(KIRO2023.is_feasible(b,current_instance))
a = KIRO2023.cost(b,current_instance)
println("Le cout de la premiere heuristique est $a")
d = KIRO2023.operational_cost(b,current_instance)
e = KIRO2023.construction_cost(b,current_instance)
println("Cout operationnel : $d, cout de construction : $e")

KIRO2023.write_solution(b,"solutions/tiny105641.json")