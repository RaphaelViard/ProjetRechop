import .KIRO2023

# Créer une copie d'une variable Solution appelée solution_copy
function copy_solution(solution::KIRO2023.Solution)
    turbine_links_copy = copy(solution.turbine_links)
    inter_station_cables_copy = copy(solution.inter_station_cables)
    substations_copy = [KIRO2023.SubStation(id=sub.id, substation_type=sub.substation_type, land_cable_type=sub.land_cable_type) for sub in solution.substations]

    return KIRO2023.Solution(turbine_links_copy, inter_station_cables_copy, substations_copy)
end


# Voisinage d'une solution réalisable : V est un voisin de S ssi on change le type et le land_cable d'une seule substation
function voisins(instance::KIRO2023.Instance, solution::KIRO2023.Solution)
    L = Vector{KIRO2023.Solution}()  # vecteur des voisins

    for i in 1:length(solution.substations)
        for j in 1:length(instance.substation_types)
            for k in 1:length(instance.land_substation_cable_types)
                voisin = copy_solution(solution)
                voisin.substations[i].substation_type = instance.substation_types[j].id
                voisin.substations[i].land_cable_type = instance.land_substation_cable_types[k]
                push!(L, voisin)
            end
        end
    end

    return L
end


#L'erreur que vous obtenez, 
#ERROR: setfield!: immutable struct of type SubStation cannot be changed, indique que vous essayez de modifier un champ d'une structure (SubStation dans ce cas) qui est 
#déclarée comme une structure immuable (immutable). En Julia, les structures immuables ne peuvent pas être modifiées après leur création.

#Créer une nouvelle structure avec les modifications : Si vous voulez maintenir l'immutabilité, créez une nouvelle structure SubStation au lieu de modifier les champs de la structure existante.

#voisin.substations[i] = KIRO2023.SubStation(id=voisin.substations[i].id, substation_type=instance.substation_types[j].id, land_cable_type=instance.land_substation_cable_types[k])


# Fonction qui retourne le meilleur voisin de la solution

function best_neighbor(instance::KIRO2023.Instance,solution::KIRO2023.Solution)
    L = voisins(instance,solution)
    best_neighbor = nothing

    for neighbor in L
        if KIRO2023.cost(instance, neighbor) < KIRO2023.cost(instance, best_neighbor) 
            best_neighbor = neighbor
        end
    end

    return best_neighbor
end
