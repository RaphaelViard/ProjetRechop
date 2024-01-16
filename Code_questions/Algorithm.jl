import .KIRO2023
#using Pkg
#Pkg.add("Plots")
using Plots
using JSON

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

function find_nearest_substation2(instance::KIRO2023.Instance)
    nearest_substations = Vector{KIRO2023.Location}()
    
    for turbine in instance.wind_turbines
        min_distance = Inf
        nearest_substation = nothing
        n = length(instance.substation_locations)
        for i in 1:n
            dist = KIRO2023.distance(turbine, instance.substation_locations[i])  + KIRO2023.distance_to_land(instance,instance.substation_locations[i].id)        
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
    for Proche in Proches
        push!(sub,KIRO2023.SubStation(id=Proche.id, substation_type=minCOUTSS,land_cable_type=minFIXCLANDCABLES) )
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


function build_first_heuristic2(instance::KIRO2023.Instance)
    nb_WT = length(current_instance.wind_turbines)
    nb_SS = length(current_instance.substation_locations)
    turb_links = zeros(Int,nb_WT)
    st_cabl = zeros(Int,nb_SS,nb_SS)
    sub = Vector{KIRO2023.SubStation}()
    Proches = find_nearest_substation(instance)
    minFIXCLANDCABLES = argmin([current_instance.land_substation_cable_types[i].fixed_cost for i in 1:length(current_instance.land_substation_cable_types)])
    minCOUTSS = argmin([current_instance.substation_types[i].cost for i in 1:length(current_instance.substation_types)])
    for Proche in Proches
        push!(sub,KIRO2023.SubStation(id=Proche.id, substation_type=minCOUTSS,land_cable_type=minFIXCLANDCABLES) )
    end   
    for i in 1:nb_WT
        dist=9999999
        k=0
        for j in 1:length(Proches)
            newdist = KIRO2023.distance(current_instance.wind_turbines[i],Proches[j]) + KIRO2023.distance_to_land(instance,Proches[j].id)
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

function build_first_heuristic3(instance::KIRO2023.Instance)
    nb_WT = length(current_instance.wind_turbines)
    nb_SS = length(current_instance.substation_locations)
    turb_links = zeros(Int,nb_WT)
    st_cabl = zeros(Int,nb_SS,nb_SS)
    sub = Vector{KIRO2023.SubStation}()
    Proches = find_nearest_substation(instance)
    minFIXCLANDCABLES = argmin([current_instance.land_substation_cable_types[i].fixed_cost for i in 1:length(current_instance.land_substation_cable_types)])
    minCOUTSS = argmin([current_instance.substation_types[i].cost for i in 1:length(current_instance.substation_types)])
    for Proche in Proches
        push!(sub,KIRO2023.SubStation(id=Proche.id, substation_type=minCOUTSS,land_cable_type=minFIXCLANDCABLES) )
    end   
    for i in 1:nb_WT
        dist=9999999
        k=0
        for j in 1:length(Proches)
            newdist = KIRO2023.distance(current_instance.wind_turbines[i],Proches[j]) + KIRO2023.distance_to_land(instance,Proches[j].id)
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



function remove_list(liste, nombre)
    return filter(x -> x != nombre, liste)
end


function build_inter_station_cables(instance::KIRO2023.Instance,solution::KIRO2023.Solution)
    indicc = argmin([instance.substation_substation_cable_types[i].fixed_cost for i in 1:length(instance.substation_substation_cable_types)])
    NSSbuilt = length(solution.substations)
    Entiers_restants = [i for i in 1:NSSbuilt]
    st_cabl2 = zeros(Int,length(instance.substation_locations),length(instance.substation_locations))
    while length(Entiers_restants) >1
        distances = Dict()
        for i in Entiers_restants
            k=0
            dist_min = Inf
            for j in Entiers_restants
                if j != i
                    dist = KIRO2023.distance_inter_station(current_instance,solution.substations[i].id,solution.substations[j].id)
                    if dist < dist_min
                        k=j
                        dist_min = dist
                    end
                end
            end
            distances[i]=[copy(k),dist_min] 
        end
        s = Entiers_restants[argmin([distances[j][2] for j in Entiers_restants])] #Probleme ici, l'argmin qu'on vient chercher n'est pas le bon des qu'on a enlevé des gens de Entiers_restants
        v = Int(distances[s][1])
        st_cabl2[solution.substations[s].id,solution.substations[v].id]= indicc
        st_cabl2[solution.substations[v].id,solution.substations[s].id] = indicc
        Entiers_restants = remove_list(Entiers_restants,s)
        Entiers_restants = remove_list(Entiers_restants,v)
    end
    return st_cabl2
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



function voisins2(instance::KIRO2023.Instance, solution::KIRO2023.Solution) #Voisin = Changement de type d'un seul cable SS-SS parmis ceux qui existent
    L = Vector{KIRO2023.Solution}()  # vecteur des voisins
    for i in 1:length(instance.substation_locations) # On décrit bien les id car les objets Locations sont rangés par ordre croissant d'id dans substation_locations
        for j in (i+1):length(instance.substation_locations)
            if solution.inter_station_cables[i, j] > 0          # S'il y a un cable entre SS i et SS j
                for p in 1:length(instance.substation_substation_cable_types)
                    new_inter_station_cables = copy(solution.inter_station_cables) 
                    new_inter_station_cables[i,j] = p   # On change le rating du cable
                    new_inter_station_cables[j,i] = p
                    voisin = KIRO2023.Solution(turbine_links=solution.turbine_links, inter_station_cables=new_inter_station_cables, substations=solution.substations)
                    push!(L, voisin)
                end
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

function best_neighbor2(instance::KIRO2023.Instance,solution::KIRO2023.Solution)
    L = voisins2(instance,solution)
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

function iter_best_neighbor2(instance::KIRO2023.Instance,solution::KIRO2023.Solution,n::Int)
    best_neighbor_iter = solution
    for i in 1:n
        best_neighbor_iter = best_neighbor2(instance,best_neighbor_iter)
    end
    return best_neighbor_iter
end

function best_neighbor_construction(instance::KIRO2023.Instance,solution::KIRO2023.Solution)
    L = voisins(instance,solution)
    best_neighbor = solution

    for neighbor in L
        if KIRO2023.construction_cost(neighbor, instance) < KIRO2023.construction_cost(best_neighbor,instance) 
            best_neighbor = neighbor
        end
    end

    return best_neighbor
end



function plot_locations_superposed(json_file)
    data = JSON.parsefile(json_file)

    wind_turbines = [(turbine["x"], turbine["y"]) for turbine in data["wind_turbines"]]
    substations = [(substation["x"], substation["y"]) for substation in data["substation_locations"]]

    min_x = min(minimum(map(p -> p[1], wind_turbines)), minimum(map(p -> p[1], substations))) - 2
    max_x = max(maximum(map(p -> p[1], wind_turbines)), maximum(map(p -> p[1], substations))) + 2

    min_y = min(minimum(map(p -> p[2], wind_turbines)), minimum(map(p -> p[2], substations))) - 2
    max_y = max(maximum(map(p -> p[2], wind_turbines)), maximum(map(p -> p[2], substations))) + 2

    plot(
        xlabel="X",
        ylabel="Y",
        xlims=(min_x, max_x),
        ylims=(min_y, max_y),
        legend=true
    )

    scatter!(map(p -> p[1], substations), map(p -> p[2], substations), color=:red, label="Substations")
    scatter!(map(p -> p[1], wind_turbines), map(p -> p[2], wind_turbines), color=:blue, label="Wind Turbines")
end


plot_locations_superposed("instances/KIRO-medium.json")

