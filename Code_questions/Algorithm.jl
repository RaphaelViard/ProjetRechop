import .KIRO2023


chemin_tiny = "instances/KIRO-tiny.json"
#chemin_small = "instances/KIRO-small.json"
#chemin_medium = "instances/KIRO-medium.json"
#chemin_large = "instances/KIRO-large.json"
#chemin_huge = "instances/KIRO-huge.json"

current_instance = KIRO2023.read_instance(chemin_tiny)

nb_WT = length(current_instance.wind_turbines) #Nombre de wind_turbine dans notre instance
nb_SS = length(current_instance.substation_locations) #Nombre de substation dans notre instance

turb_links = zeros(Int,nb_WT) #Les trois tableaux suivants sont ceux qu'on va mettre dans notre type "solution" pour créer le json
st_cabl = zeros(Int,nb_SS)
sub = Vector{KIRO2023.SubStation}() #Les substations qu'on va construire

function find_nearest_substation(instance::Instance)
    nearest_substations = Vector{KIRO2023.SubStation}()
    
    for turbine in instance.wind_turbines
        min_distance = Inf
        nearest_substation = nothing
        
        for substation in instance.substation_locations
            dist = distance(turbine, substation) # Utilisation de la fonction distance
            
            if dist < min_distance
                min_distance = dist
                nearest_substation = substation
            end
        end
        
        push!(nearest_substations, nearest_substation)
    end
    
    return nearest_substations
end



# Créer une copie d'une variable Solution appelée solution_copy
function copy_solution(solution::Solution)
    turbine_links_copy = copy(solution.turbine_links)
    inter_station_cables_copy = copy(solution.inter_station_cables)
    substations_copy = [SubStation(id=sub.id, substation_type=sub.substation_type, land_cable_type=sub.land_cable_type) for sub in solution.substations]

    return Solution(turbine_links_copy, inter_station_cables_copy, substations_copy)
end


# Voisinage d'une solution réalisable : V est un voisin de S ssi on change le type et le land_cable d'une seule substation

function voisins(instance::Instance,solution::Solution)

    L=Vector{Solution}()    # vecteur des voisins

    for SubStation in solution.substations
        for sub_type in instance.substation_types
            for cable_type in instance.land_substation_cable_types
                voisin = copy(solution)
                voisin.SubStation.substation_type = sub_type
                voisin.SubStation.land_cable_type = cable_type
                push!(L,voisin)

    return L
end

# Fonction qui retourne le meilleur voisin de la solution

function best_neighbor(instance::Instance,solution::Solution)
    L = voisins(instance,solution)
    best_neighbor = nothing

    for neighbor in L
        if cost(instance, neighbor) < cost(instance, best_neighbor) 
            best_neighbor = neighbor

    return best_neighbor
end

        