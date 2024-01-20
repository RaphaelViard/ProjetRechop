import KIRO2023

include("Algorithm.jl")

chemin_tiny = "instances/KIRO-tiny.json"
chemin_small = "instances/KIRO-small.json"
chemin_medium = "instances/KIRO-medium.json"
chemin_large = "instances/KIRO-large.json"
chemin_huge = "instances/KIRO-huge.json"

current_instance = KIRO2023.read_instance(chemin_small)

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


#Heuristique_voisins = iter_best_neighbor(current_instance,Heuristique,5)
#KIRO2023.is_feasible(Heuristique_voisins,current_instance)
#c = KIRO2023.cost(Heuristique_voisins,current_instance)
#println("Le meilleur voisin a un cout de $c")


a,b,c,KK = build_first_heuristic(current_instance)



#cost,KK = random_sol(current_instance)

#for i in 1:10000
#   cost,sol=iter_random(current_instance,500)
#   cost2,sol2=iter_random(current_instance,5)
#    println("début du best neighbor :")
#    soly=iter_best_neighbor2(current_instance,iter_best_neighbor(current_instance,sol,10),5)
#    soly2=iter_best_neighbor2(current_instance,iter_best_neighbor(current_instance,sol2,10),5)
#    println("Cout apres random ET apres best neighb :")
#    println(KIRO2023.cost(soly,current_instance))
#    println(KIRO2023.cost(soly2,current_instance))
#    if KIRO2023.cost(soly,current_instance)<8800
#        KIRO2023.write_solution(soly,"solutions/large$(KIRO2023.cost(soly,current_instance)).json")
#    end
#    if KIRO2023.cost(soly2,current_instance)<8800
#        KIRO2023.write_solution(soly,"solutions/large$(KIRO2023.cost(soly2,current_instance)).json")
#    end
#end


sol = KIRO2023.read_solution("solutions/small3249.json",current_instance)
println(KIRO2023.cost(iter_best_neighbor(current_instance,sol,2),current_instance))
println(length(sol.substations))
new_turb = zeros(Int,length(current_instance.wind_turbines))
for i in 1:length(new_turb)
    k=-1
    distmin=Inf
    for j in 1:length(sol.substations)
        if KIRO2023.distance(current_instance.substation_locations[sol.substations[j].id],current_instance.wind_turbines[i])< distmin
            distmin= KIRO2023.distance(current_instance.substation_locations[sol.substations[j].id],current_instance.wind_turbines[i])
            k=j
        end
        new_turb[i]=k
    end
end

newsol = KIRO2023.Solution(new_turb,sol.inter_station_cables,sol.substations)
println(KIRO2023.cost(newsol,current_instance))
newwsol = iter_best_neighbor(current_instance,newsol,20)
println(KIRO2023.cost(newwsol,current_instance))
KIRO2023.write_solution(newwsol,"solutions/small2318.json")


