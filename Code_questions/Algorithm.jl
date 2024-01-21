import KIRO2023
#using Pkg
#Pkg.add("Random")
using Plots
using JSON
using Random

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
        dist =9999999
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




function remove_list(liste, nombre)
    return filter(x -> x != nombre, liste)
end


function build_inter_station_cables(instance::KIRO2023.Instance,solution::KIRO2023.Solution,op)
    #indicc = argmin([instance.substation_substation_cable_types[i].fixed_cost for i in 1:length(instance.substation_substation_cable_types)])
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
        s = Entiers_restants[argmax([distances[j][2] for j in Entiers_restants])] #Probleme ici, l'argmin qu'on vient chercher n'est pas le bon des qu'on a enlevé des gens de Entiers_restants
        v = Int(distances[s][1])
        st_cabl2[solution.substations[s].id,solution.substations[v].id]= op#ndicc
        st_cabl2[solution.substations[v].id,solution.substations[s].id] = op#ndicc
        Entiers_restants = remove_list(Entiers_restants,s)
        Entiers_restants = remove_list(Entiers_restants,v)
    end
    return st_cabl2
end

function itt_best_cabl(instance::KIRO2023.Instance,solution::KIRO2023.Solution)
    cout_min = Inf
    k=-1
    for i in 1:length(instance.substation_substation_cable_types)
        Sol = KIRO2023.Solution(substations=solution.substations,inter_station_cables = build_inter_station_cables(instance,solution,i),turbine_links=solution.turbine_links)
        if KIRO2023.cost(Sol,instance) < cout_min
            cout_min = KIRO2023.cost(Sol,instance)
            k=i
        end
    end
    return build_inter_station_cables(instance,solution,k)
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


function voisins3(instance::KIRO2023.Instance, solution::KIRO2023.Solution)
    L = Vector{KIRO2023.Solution}()  # vecteur des voisins
    for i in 1:length(instance.substation_locations)
        indices = findall(x -> x == i, solution.turbine_links)
        for k in 1:length(instance.substation_locations)
            turbine2 = copy(solution.turbine_links)
            for j in 1:length(indices)
            #    if iseven(j)
                    turbine2[indices[j]]=k
            #    end
            end
            sub2 = copy(solution.substations)
            for p in 1:length(sub2)
                if sub2[p].id==i
                    newSS = KIRO2023.SubStation(id=k,substation_type=sub2[p].substation_type,land_cable_type=sub2[p].land_cable_type)
                    sub2[p]=newSS
                end
            end
        push!(L,KIRO2023.Solution(turbine_links=turbine2,inter_station_cables=solution.inter_station_cables,substations=sub2))
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

function best_neighbor_construction()
    L = voisins(instance,solution)
    best_neighbor = solution

    for neighbor in L
        if KIRO2023.construction_cost(neighbor, instance) < KIRO2023.construction_cost(best_neighbor,instance) 
            best_neighbor = neighbor
        end
    end

    return best_neighbor
end


# On trouve les deux SS qui sont le plus semblables du point de vue de leur capacité (land_cable_rating et substation_rating)
function find_same_capacity_SS(instance::KIRO2023.Instance,solution::KIRO2023.Solution)
    NSSbuilt = length(solution.substations)

    common_capacity = 0
    capacity_difference = 99999999999999
    (k_id,l_id) = (1,1)

    for i in 1:NSSbuilt
        id_i = KIRO2023.id((solution.substations)[i])
        SS_type_i = KIRO2023.substation_type((solution.substations)[i])
        land_cable_type_i = KIRO2023.land_cable_type((solution.substations)[i])

        SS_rating_i = KIRO2023.substation_rating(instance,SS_type_i)
        land_cable_rating_i = KIRO2023.land_cable_rating(instance,land_cable_type_i)

        capacity_SS_i = min(SS_rating_i,land_cable_rating_i)

        for j in i+1:length(NSSbuilt)
            id_j = KIRO2023.id((solution.substations)[j])
            SS_type_j = KIRO2023.substation_type((solution.substations)[j])
            land_cable_type_j = KIRO2023.land_cable_type((solution.substations)[j])

            SS_rating_j = KIRO2023.substation_rating(instance,SS_type_j)
            and_cable_rating_j = KIRO2023.land_cable_rating(instance,land_cable_type_j)

            capacity_SS_j = min(SS_rating_j,land_cable_rating_j)

            new_capacity_difference = abs(capacity_SS_i-capacity_SS_j)

            if  new_capacity_difference < capacity_difference
                capacity_difference = new_capacity_difference
                k=id_i
                l=id_j
                common_capacity = capacity_SS_i
            end
        end
        return (k_id,l_id,common_capacity)
    end
end 

function link_same_capacity_SS(instance::KIRO2023.Instance,solution::KIRO2023.Solution)
    (k,l,common_capacity) = find_same_capacity_SS(instance,solution)
    new_inter_station_cables= copy(solution.inter_station_cables)
    # On cherche le cable qui permet de transporter autant d'électricité que la capacite commune
    # i.e on cherche le cable de capacité directement supérieure à la capacité commune
    i=1
    while (KIRO2023.inter_substation_cable_rating(instance,i)<common_capacity)
        i=i+1
    end
    cable_id =i

    new_inter_station_cables[k,l] = cable_id

    t=copy(solution.turbine_links)
    w= copy(solution.substations)

    a = KIRO2023.Solution(turbine_links = t,inter_station_cables=new_inter_station_cables,substations=w)

    return a
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


function build_medium(instance::KIRO2023.Instance)
    n=18
    p=23
    nb_WT = length(instance.wind_turbines)
    nb_SS = length(instance.substation_locations)
    turb_links = zeros(Int,nb_WT)
    st_cabl = zeros(Int,nb_SS,nb_SS)
    sub = Vector{KIRO2023.SubStation}()
    f = rand(1:length(instance.substation_substation_cable_types))
    st_cabl[n,p] =f
    st_cabl[p,n] = f
    push!(sub, KIRO2023.SubStation(id=n,substation_type=1,land_cable_type=1))
    push!(sub, KIRO2023.SubStation(id=p,substation_type=1,land_cable_type=1))
    for i in 1:length(instance.wind_turbines)
        if KIRO2023.distance(instance.wind_turbines[i],instance.substation_locations[n]) < KIRO2023.distance(instance.wind_turbines[i],instance.substation_locations[p])
            turb_links[i]= n
        else
            turb_links[i]=p
        end
    end
    if KIRO2023.cost(KIRO2023.Solution(turb_links,st_cabl,sub),instance) < KIRO2023.cost(KIRO2023.Solution(turb_links,zeros(Int,nb_SS,nb_SS),sub),instance)
        return KIRO2023.Solution(turb_links,st_cabl,sub)
    else
        return KIRO2023.Solution(turb_links,zeros(Int,nb_SS,nb_SS),sub)
    end
end



function build_2ss(instance::KIRO2023.Instance)
    L = Vector{KIRO2023.Solution}()
    nb_WT = length(instance.wind_turbines)
    nb_SS = length(instance.substation_locations)
    for i in 1:length(instance.substation_locations)
        for j in 1:length(instance.substation_locations)
            if i!=j && instance.substation_locations[i].x >= 63 && instance.substation_locations[j].x >= 63
                turb_links = zeros(Int,nb_WT)
                st_cabl = zeros(Int,nb_SS,nb_SS)
                sub = Vector{KIRO2023.SubStation}()
                f = rand(1:length(instance.substation_substation_cable_types))
                st_cabl[i,j] =f
                st_cabl[j,i] = f
                push!(sub, KIRO2023.SubStation(id=i,substation_type=1,land_cable_type=1))
                push!(sub, KIRO2023.SubStation(id=j,substation_type=1,land_cable_type=1))
                for k in 1:length(instance.wind_turbines)
                    if KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[i]) < KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[j])
                        turb_links[k]= i
                    else
                        turb_links[k]=j
                    end
                end
                push!(L,KIRO2023.Solution(turb_links,st_cabl,sub))
                push!(L,KIRO2023.Solution(turb_links,zeros(Int,nb_SS,nb_SS),sub))
            end
        end
    end
    k=0
    dist_min = Inf
    for i in 1:length(L)
        if KIRO2023.cost(L[i],instance)<dist_min
            dist_min = KIRO2023.cost(L[i],instance)
            k=i
        end
    end
    return L[k]
end





function build_3ss(instance::KIRO2023.Instance)
    L = Vector{KIRO2023.Solution}()
    nb_WT = length(instance.wind_turbines)
    nb_SS = length(instance.substation_locations)
    for i in 1:length(instance.substation_locations)
        for j in 1:length(instance.substation_locations)
            for p in 1:length(instance.substation_locations)
                if i!=j && j!= p && i!=p && instance.substation_locations[i].x <=  60 && instance.substation_locations[i].x >=  40 && instance.substation_locations[j].x <=  60 && instance.substation_locations[j].x >=  40 && instance.substation_locations[p].x <=  60 && instance.substation_locations[p].x >=  40
                    turb_links = zeros(Int,nb_WT)
                    st_cabl1 = zeros(Int,nb_SS,nb_SS)
                    st_cabl2= zeros(Int,nb_SS,nb_SS)
                    st_cabl3= zeros(Int,nb_SS,nb_SS)
                    sub = Vector{KIRO2023.SubStation}()
                    f = rand(1:length(instance.substation_substation_cable_types))
                    st_cabl[i,j] =f
                    st_cabl[j,i] = f
                    st_cabl2[i,p]=f
                    st_cabl2[p,i]=f
                    st_cabl3[j,p]=f
                    st_cabl3[p,j]=f
                    push!(sub, KIRO2023.SubStation(id=i,substation_type=1,land_cable_type=1))
                    push!(sub, KIRO2023.SubStation(id=j,substation_type=1,land_cable_type=1))
                    push!(sub,KIRO2023.SubStation(id=p,substation_type=1,land_cable_type=1))
                    for k in 1:length(instance.wind_turbines)
                        if KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[i]) <= KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[j]) && KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[i]) <= KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[p])
                            turb_links[k]= i
                        else
                            if KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[j]) <= KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[p])
                                turb_links[k]=j                             
                            else
                                turb_links[k]=p
                            end
                        end
                    end
                    push!(L,KIRO2023.Solution(turb_links,st_cabl1,sub))
                    push!(L,KIRO2023.Solution(turb_links,st_cabl2,sub))
                    push!(L,KIRO2023.Solution(turb_links,st_cabl3,sub))
                    push!(L,KIRO2023.Solution(turb_links,zeros(Int,nb_SS,nb_SS),sub))
                end
            end
        end
    end
    k=0
    dist_min = Inf
    for i in 1:length(L)
        if KIRO2023.cost(L[i],instance)<dist_min
            dist_min = KIRO2023.cost(L[i],instance)
            k=i
        end
    end
    return L[k]
end

function deuxieme_val(liste)
    length(liste) < 2 && error("La liste ne contient pas au moins deux éléments.")
    return maximum(setdiff(liste, [maximum(liste)]))
end


function build_ss_admissibles(instance::KIRO2023.Instance)
    L = Vector{Int}()
    alpha = deuxieme_val([instance.substation_locations[i].x for i in 1:length(instance.substation_locations)])
    for i in 1:length(instance.substation_locations)
        if instance.substation_locations[i].x > 63
            push!(L,i)
        end
    end
    return L 
end

function build_4ss(instance::KIRO2023.Instance)
    L = Vector{KIRO2023.Solution}()
    indices = build_ss_admissibles(instance)
    nb_WT = length(instance.wind_turbines)
    nb_SS = length(instance.substation_locations)
    for i in 1:length(indices)
        for j in 1:length(indices)
            for p in 1:length(indices)
                for ll in 1:length(indices)
                        turb_links = zeros(Int,nb_WT)
#                        st_cabl1 = zeros(Int,nb_SS,nb_SS)
#                        st_cabl2= zeros(Int,nb_SS,nb_SS)
#                        st_cabl3= zeros(Int,nb_SS,nb_SS)
                        sub = Vector{KIRO2023.SubStation}()
                        f = rand(1:length(instance.substation_substation_cable_types))
                        st_cabl[i,j] =f
                        st_cabl[j,i] = f
#                        st_cabl2[i,p]=f
#                        st_cabl2[p,i]=f
#                        st_cabl2[j,ll]=f
#                        st_cabl2[ll,j]=f
                        push!(sub, KIRO2023.SubStation(id=i,substation_type=1,land_cable_type=1))
                        push!(sub, KIRO2023.SubStation(id=j,substation_type=1,land_cable_type=1))
                        push!(sub,KIRO2023.SubStation(id=p,substation_type=1,land_cable_type=1))
                        push!(sub,KIRO2023.SubStation(id=ll,substation_type=1,land_cable_type=1))
                        for k in 1:length(instance.wind_turbines)
                            if KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[i]) <= KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[j]) && KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[i]) <= KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[p]) && KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[i]) <= KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[ll])
                                turb_links[k]= i
                            else
                                if KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[j]) <= KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[p]) && KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[j]) <= KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[ll])
                                    turb_links[k]=j                             
                                else
                                    if KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[p]) <= KIRO2023.distance(instance.wind_turbines[k],instance.substation_locations[ll])
                                        turb_links[k]=p
                                    else
                                        turb_links[k]=ll
                                    end
                                end
                            end
                        end
 #                       push!(L,KIRO2023.Solution(turb_links,st_cabl1,sub))
 #                       push!(L,KIRO2023.Solution(turb_links,st_cabl2,sub))
 #                       push!(L,KIRO2023.Solution(turb_links,st_cabl3,sub))
                        push!(L,KIRO2023.Solution(turb_links,zeros(Int,nb_SS,nb_SS),sub))
                end
            end
        end
    end
    k=0
    dist_min = Inf
    for i in 1:length(L)
        if KIRO2023.cost(L[i],instance)<dist_min
            dist_min = KIRO2023.cost(L[i],instance)
            k=i
        end
    end
    return L[k]
end


function compute_new_heuristic(solution::KIRO2023.Solution,instance::KIRO2023.Instance)
    L = Vector{KIRO2023.Solution}()
    turb_links1 = solution.turbine_links
    st_cabl1 = solution.inter_station_cables
    sub1 = solution.substations
    SSused = []
    for ss in turb_links1
        if !(ss in SSused)
            push!(SSused,ss)
        end
    end
    for i in SSused
        for j in SSused
            if j!=i
                turb = copy(turb_links1)
                st_cabl = copy(st_cabl1)
                sub = copy(sub1)
                for p in 1:length(turb)
                    if turb[p] == i
                        turb[p] = j
                    end
                end
                u = [a.id for a in sub]
                indice = findfirst(x -> x == i, u)
                splice!(sub,indice) 
                push!(L,KIRO2023.Solution(turbine_links=turb,inter_station_cables=st_cabl,substations=sub))
            end
        end
    end
    k=0
    dist_min = Inf
    for i in 1:length(L)
        if KIRO2023.cost(L[i],instance)<dist_min
            dist_min = KIRO2023.cost(L[i],instance)
            k=i
        end
    end
    return L[k]
end



function extract_sublist(l, k)
    # Vérifiez si la liste a une taille suffisante
    if length(l) < k
        error("La liste est plus petite que la taille de la sous-liste souhaitée.")
    end
    
    # Générer un indice aléatoire sans remplacement
    indices = randperm(length(l))[1:k]
    
    # Extraire les éléments correspondants dans la sous-liste
    p = l[indices]
    
    return p
end
function cho!(l)
    if isempty(l)
        error("La liste est vide.")
    end
    index = rand(1:length(l))
    selected_element = l[index]
    deleteat!(l, index)
    return selected_element
end

function random_sol(instance::KIRO2023.Instance)
    nb_SSmax = length(instance.substation_locations)
    nbSS = rand(2:3)#rand(1:nb_SSmax)
    nb_WT = length(current_instance.wind_turbines)
    turb_links = zeros(Int,nb_WT)
    st_cabl = zeros(Int,nb_SSmax,nb_SSmax)
    sub = Vector{KIRO2023.SubStation}()
    while  length(sub)<nbSS
        newid = rand(1:length(instance.substation_locations))
        if !(newid in [sub[i].id for i in 1:length(sub)])
            push!(sub,KIRO2023.SubStation(id=newid,substation_type=rand(1:length(instance.substation_types)),land_cable_type=rand(1:length(instance.land_substation_cable_types))))
        end
    end
    listess = [sub[i].id for i in 1:length(sub)]
    for i in 1:length(turb_links)
        turb_links[i] = rand(listess)
    end
    Sol1 = KIRO2023.Solution(turb_links,st_cabl,sub)
    if nbSS > 1
        k = Int(rand(1:nbSS//2))
        st_cabl22 = zeros(Int,nb_SSmax,nb_SSmax)
        XX = extract_sublist(listess,2*k)
        while length(XX)>0
            i = cho!(XX)
            j = cho!(XX)
            ff = rand(1:length(instance.substation_substation_cable_types))
            st_cabl22[i,j]=ff
            st_cabl22[j,i]=ff
        end
    
    #st_cabl2=itt_best_cabl(instance,Sol1)
    #Sol11 = iter_best_neighbor(instance,Sol1,10)
        Sol2 = KIRO2023.Solution(turb_links,st_cabl22,sub)

    #Sol22 =iter_best_neighbor(instance,Sol2,10)
        if KIRO2023.cost(Sol2,instance) < KIRO2023.cost(Sol1,instance)
            return KIRO2023.cost(Sol2,instance),Sol2
        end
    end
    return KIRO2023.cost(Sol1,instance),Sol1

end

function iter_random(instance::KIRO2023.Instance,n::Int)
    cout_min,Sol_min =random_sol(instance)
    println(cout_min)
    for i in 1:n
        cout,sol=random_sol(instance)
        if cout<cout_min
            cout_min=cout
            Sol_min=sol
            println(cout_min)
        end
    end
    return cout_min,Sol_min
end

#plot_locations_superposed("instances/KIRO-medium.json")

#huge : >62 : pour avoir les 2 dernieres rangées
#large : >60
#medium : > 43
#small: >35
