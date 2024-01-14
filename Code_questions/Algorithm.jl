import .KIRO2023

# Créer une copie d'une variable Solution appelée solution_copy
function copy_solution(solution::KIRO2023.Solution)
    turbine_links_copy = copy(solution.turbine_links)
    inter_station_cables_copy = copy(solution.inter_station_cables)
    substations_copy = [KIRO2023.SubStation(id=sub.id, substation_type=sub.substation_type, land_cable_type=sub.land_cable_type) for sub in solution.substations]

    return KIRO2023.Solution(turbine_links_copy, inter_station_cables_copy, substations_copy)
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