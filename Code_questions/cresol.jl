import KIRO2023

include("Algorithm.jl")

chemin_tiny = "instances/KIRO-tiny.json"
chemin_small = "instances/KIRO-small.json"
chemin_medium = "instances/KIRO-medium.json"
chemin_large = "instances/KIRO-large.json"
chemin_huge = "instances/KIRO-huge.json"

current_instance = KIRO2023.read_instance(chemin_large)

tiny_instance = KIRO2023.read_instance(chemin_tiny)
small_instance = KIRO2023.read_instance(chemin_small)
medium_instance = KIRO2023.read_instance(chemin_medium)
large_instance = KIRO2023.read_instance(chemin_large)
huge_instance = KIRO2023.read_instance(chemin_huge)

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


turb_links, st_cabl,sub,Heuristique2 = build_first_heuristic(current_instance)

st_cabl2 = build_inter_station_cables(current_instance,Heuristique2,1)

Heuristique = KIRO2023.Solution(turbine_links=turb_links,inter_station_cables=st_cabl,substations=sub)


println(KIRO2023.is_feasible(Heuristique,current_instance))
a = KIRO2023.cost(Heuristique,current_instance)
println("Le cout de la premiere heuristique est $a")
d = KIRO2023.operational_cost(Heuristique,current_instance)
e = KIRO2023.construction_cost(Heuristique,current_instance)
println("Cout operationnel : $d, cout de construction : $e")


soltiny = KIRO2023.read_solution("solutions/KIRO-tiny-sol_16.json",tiny_instance)
solsmall = KIRO2023.read_solution("solutions/KIRO-small-sol_16.json",small_instance)
solmedium = KIRO2023.read_solution("solutions/KIRO-medium-sol_16.json",medium_instance)
sollarge = KIRO2023.read_solution("solutions/KIRO-large-sol_16.json",large_instance)
solhuge = KIRO2023.read_solution("solutions/KIRO-huge-sol_16.json",huge_instance)
println(KIRO2023.is_feasible(soltiny,tiny_instance))
println(KIRO2023.cost(soltiny,tiny_instance))
println(KIRO2023.is_feasible(solsmall,small_instance))
println(KIRO2023.cost(solsmall,small_instance))
println(KIRO2023.is_feasible(solmedium,medium_instance))
println(KIRO2023.cost(solmedium,medium_instance))
println(KIRO2023.is_feasible(sollarge,large_instance))
println(KIRO2023.cost(sollarge,large_instance))
println(KIRO2023.is_feasible(solhuge,huge_instance))
println(KIRO2023.cost(solhuge,huge_instance))
nbvariables = 9 +81*3 + 4*length(huge_instance.substation_types) + 3*length(huge_instance.wind_turbines)+5*length(huge_instance.land_substation_cable_types)+5*length(huge_instance.substation_substation_cable_types)+3*length(huge_instance.wind_scenarios)
println(nbvariables)