import .KIRO2023

# Créer une copie d'une variable Solution appelée solution_copy
function copy_solution(solution::KIRO2023.Solution)
    turbine_links_copy = copy(solution.turbine_links)
    inter_station_cables_copy = copy(solution.inter_station_cables)
    substations_copy = [KIRO2023.SubStation(id=sub.id, substation_type=sub.substation_type, land_cable_type=sub.land_cable_type) for sub in solution.substations]

    return KIRO2023.Solution(turbine_links_copy, inter_station_cables_copy, substations_copy)
end


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


function build_first_heuristic(instance::KIRO2023.Instance)
    nb_WT = length(current_instance.wind_turbines)
    nb_SS = length(current_instance.substation_locations)
    turb_links = zeros(Int,nb_WT)
    st_cabl = zeros(Int,nb_SS,nb_SS)
    sub = Vector{KIRO2023.SubStation}()
    Proches = find_nearest_substation(instance)
    minFIXCLANDCABLES = argmin([current_instance.land_substation_cable_types[i].fixed_cost for i in 1:length(current_instance.land_substation_cable_types)])
    minCOUTSS = argmin([current_instance.substation_types[i].cost for i in 1:length(current_instance.substation_types)])
    for i in 1:length(Proches)
        push!(sub,KIRO2023.SubStation(id=Proches[i].id, substation_type=minCOUTSS,land_cable_type=minFIXCLANDCABLES) )
    end   
    for i in 1:nb_WT
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
    return turb_links,st_cabl,sub,Heuristique
end

function voisins(instance::KIRO2023.Instance, solution::KIRO2023.Solution)
    L = Vector{KIRO2023.Solution}()  # vecteur des voisins

    for i in 1:length(solution.substations)
        for j in 1:length(instance.substation_types)
            for k in 1:length(instance.land_substation_cable_types)
                # On créé un nouveau vecteur pour les Substations du voisin
                new_substations = copy(solution.substations)    
                # On modifie le type de susbtation et le type de cable, tout en gardant le meme indicateur de position
                new_substations[i] = KIRO2023.SubStation(id=solution.substations[i].id, substation_type=instance.substation_types[j].id, land_cable_type=instance.land_substation_cable_types[k].id)
                voisin = KIRO2023.Solution(turbine_links=solution.turbine_links,inter_station_cables=solution.inter_station_cables, substations=new_substations)
                push!(L,voisin)
            end
        end
    end 
    return L
end


# Fonction qui retourne le meilleur voisin de la solution

function best_neighbor(instance::KIRO2023.Instance,solution::KIRO2023.Solution)
    L = voisins(instance,solution)
    best_neighbor = solution

    for neighbor in L
        if KIRO2023.cost(neighbor, instance) < KIRO2023.cost(best_neighbor,instance) 
            best_neighbor = neighbor
        end
    end

    return best_neighbor
end

function iter_best_neighbor(instance::KIRO2023.Instance,solution::KIRO2023.Solution,n::Int)
    best_neighbor_iter = solution
    for i in 1:n
        best_neighbor_iter = best_neighbor(instance,best_neighbor_iter)
    end
    return best_neighbor_iter
end