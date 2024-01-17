import .KIRO2023

include("Algorithm.jl")

chemin_tiny = "instances/KIRO-tiny.json"
chemin_small = "instances/KIRO-small.json"
chemin_medium = "instances/KIRO-medium.json"
chemin_large = "instances/KIRO-large.json"
chemin_huge = "instances/KIRO-huge.json"

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


turb_links, st_cabl,sub,Heuristique2 = build_first_heuristic(current_instance)
st_cabl2 = build_inter_station_cables(current_instance,Heuristique2,1)

Heuristique = KIRO2023.Solution(turbine_links=turb_links,inter_station_cables=st_cabl,substations=sub)


println(KIRO2023.is_feasible(Heuristique,current_instance))
a = KIRO2023.cost(Heuristique,current_instance)
println("Le cout de la premiere heuristique est $a")
d = KIRO2023.operational_cost(Heuristique,current_instance)
e = KIRO2023.construction_cost(Heuristique,current_instance)
println("Cout operationnel : $d, cout de construction : $e")




Heuristique_voisins = iter_best_neighbor(current_instance,Heuristique,10)
KIRO2023.is_feasible(Heuristique_voisins,current_instance)
c = KIRO2023.cost(Heuristique_voisins,current_instance)

println("Le meilleur voisin a un cout de $c")

d = KIRO2023.operational_cost(Heuristique_voisins,current_instance)
e = KIRO2023.construction_cost(Heuristique_voisins,current_instance)
println("Cout operationnel : $d, cout de construction : $e")

# Heuristique avec des cables entre les stations

Heuristique_voisins_inter_cables = link_same_capacity_SS(current_instance,Heuristique_voisins)
KIRO2023.is_feasible(Heuristique_voisins_inter_cables,current_instance)

f = KIRO2023.cost(Heuristique_voisins_inter_cables,current_instance)

println("Le meilleur voisin avec cables entre stations a un cout de $f")

g = KIRO2023.operational_cost(Heuristique_voisins_inter_cables,current_instance)
h = KIRO2023.construction_cost(Heuristique_voisins_inter_cables,current_instance)
println("Cout operationnel : $g, cout de construction : $h")

#println("Heuristique2 a un cout de $c")
#println("Cout operationnel : $d, cout de construction : $e")

#path1= "solutions/huge.json.json"
#Soltangz = KIRO2023.read_solution(path1)
#KIRO2023.nb_station_locations(current_instance)
#Heuristique1 = KIRO2023.Solution(turbine_links = Soltangz.turbine_links,inter_station_cables=zeros(Int,81,81),substations=Soltangz.substations)
#println(KIRO2023.is_feasible(Heuristique1,current_instance))
#KIRO2023.write_solution(Heuristique_voisins,"solutions/small3416.json")


