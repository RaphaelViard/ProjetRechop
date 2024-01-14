import .KIRO2023

include("Algorithm.jl")

chemin_tiny = "instances/KIRO-tiny.json"
chemin_small = "instances/KIRO-small.json"
chemin_medium = "instances/KIRO-medium.json"
chemin_large = "instances/KIRO-large.json"
chemin_huge = "instances/KIRO-huge.json"

current_instance = KIRO2023.read_instance(chemin_medium)

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
st_cabl2 = zeros(Int,CardVS,CardVS)
#st_cabl[i,j]> 0 ssi SS i et j reliées taille VS x VS
indicc = argmin([current_instance.substation_substation_cable_types[i].fixed_cost for i in 1:length(current_instance.substation_substation_cable_types)])
NSSbuilt = length(sub)

function remove_list(liste, nombre)
    return filter(x -> x != nombre, liste)
end

Entiers_restants = [i for i in 1:NSSbuilt]
while length(Entiers_restants) >1
    distances = []
    for i in Entiers_restants
        k=0
        dist_min = Inf
        for j in Entiers_restants
            if j != i
                dist = KIRO2023.distance_inter_station(current_instance,sub[i].id,sub[j].id)
                if dist < dist_min
                    k=j
                    dist_min = dist
                end
            end
        end
        push!(distances,(copy(k),dist_min))
    end
    s = argmin([distance[2] for distance in distances])
    v = distances[s][1]
    st_cabl2[sub[s].id,sub[v].id]= indicc
    st_cabl2[sub[v].id,sub[s].id] = indicc
    global Entiers_restants = remove_list(Entiers_restants,s)
    global Entiers_restants = remove_list(Entiers_restants,v)
end

Heuristique = KIRO2023.Solution(turbine_links=turb_links,inter_station_cables=st_cabl2,substations=sub)

println(KIRO2023.is_feasible(Heuristique,current_instance))
a = KIRO2023.cost(Heuristique,current_instance)
println("Le cout de la premiere heuristique est $a")
d = KIRO2023.operational_cost(Heuristique,current_instance)
e = KIRO2023.construction_cost(Heuristique,current_instance)
println("Cout operationnel : $d, cout de construction : $e")




Heuristique_voisins = iter_best_neighbor2(current_instance,iter_best_neighbor(current_instance,Heuristique,5),5)


KIRO2023.is_feasible(Heuristique_voisins,current_instance)
c = KIRO2023.cost(Heuristique_voisins,current_instance)

println("Le meilleur voisin a un cout de $c")

d = KIRO2023.operational_cost(Heuristique_voisins,current_instance)
e = KIRO2023.construction_cost(Heuristique_voisins,current_instance)
println("Cout operationnel : $d, cout de construction : $e")


#println("Heuristique2 a un cout de $c")
#println("Cout operationnel : $d, cout de construction : $e")


#path1= "solutions/huge.json.json"
#Soltangz = KIRO2023.read_solution(path1)
#KIRO2023.nb_station_locations(current_instance)
#Heuristique1 = KIRO2023.Solution(turbine_links = Soltangz.turbine_links,inter_station_cables=zeros(Int,81,81),substations=Soltangz.substations)
#println(KIRO2023.is_feasible(Heuristique1,current_instance))
#KIRO2023.write_solution(Solultime,"solutions/HUGE10000.json")
