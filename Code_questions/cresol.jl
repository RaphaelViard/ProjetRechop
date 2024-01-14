import .KIRO2023

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




#Les trois tableaux suivants sont ceux qu'on va mettre dans notre type "solution" pour créer le json
turb_links = zeros(Int,nb_WT)  #turb_links[i]=j ssi la WT i est liée a SS j 
st_cabl = zeros(Int,nb_SS,nb_SS)#  si [i,j]> 0 : SS i et j sont liées; avec le cable d'id azazd[i,j]
sub = Vector{KIRO2023.SubStation}() #Les substations qu'on va construire (id : l'id de la substation_location)

function find_nearest_substation(instance::KIRO2023.Instance)
    nearest_substations = Vector{KIRO2023.Location}()
    
    for turbine in instance.wind_turbines
        min_distance = Inf
        nearest_substation = nothing
        n = length(instance.substation_locations)
        for i in 1:n
            dist = KIRO2023.distance(turbine, instance.substation_locations[i])            
            if dist < min_distance
                min_distance = dist
                nearest_substation = instance.substation_locations[i]
            end
        end
        if !(nearest_substation in nearest_substations)
            push!(nearest_substations, nearest_substation)
        end
    end
    
    return nearest_substations #Liste de location (et donc d'id)
end


Proches = find_nearest_substation(current_instance) #On selectionne les SS qu'on va construire -> Une liste de location

minFIXCLANDCABLES = argmin([current_instance.land_substation_cable_types[i].fixed_cost for i in 1:length(current_instance.land_substation_cable_types)])
minCOUTSS = min_cost_index = argmin([current_instance.substation_types[i].cost for i in 1:length(current_instance.substation_types)]) #On prend celles avec le plus petit cout fixe

for i in 1:length(Proches)
    push!(sub,KIRO2023.SubStation(id=Proches[i].id, substation_type=minCOUTSS,land_cable_type=minFIXCLANDCABLES) )
end

for i in 1:CardVT
    dist=9999999
    k=0
    for j in 1:length(Proches)
        newdist = KIRO2023.distance(current_instance.wind_turbines[i],Proches[j])
        if  newdist < dist
            dist = newdist
            k=j
        end
    end
    turb_links[i]=Proches[k].id
end


Heuristique = KIRO2023.Solution(turbine_links = turb_links,inter_station_cables=st_cabl,substations=sub)




a = KIRO2023.cost(Heuristique,current_instance)
println("Le cout de la premiere heuristique est $a")




Heuristique_voisins = iter_best_neighbor(current_instance,Heuristique,10)

c = KIRO2023.cost(Heuristique_voisins,current_instance)

println("Le meilleur voisin a un cout de $c")
KIRO2023.is_feasible(Heuristique_voisins,current_instance)
d = KIRO2023.operational_cost(Heuristique_voisins,current_instance)
e = KIRO2023.construction_cost(Heuristique_voisins,current_instance)
println("Cout operationnel : $d, cout de construction : $e")



#path1= "solutions/huge.json.json"
#Soltangz = KIRO2023.read_solution(path1)
#KIRO2023.nb_station_locations(current_instance)
#Heuristique1 = KIRO2023.Solution(turbine_links = Soltangz.turbine_links,inter_station_cables=zeros(Int,81,81),substations=Soltangz.substations)
#println(KIRO2023.is_feasible(Heuristique1,current_instance))
#KIRO2023.write_solution(Solultime,"solutions/HUGE10000.json")
