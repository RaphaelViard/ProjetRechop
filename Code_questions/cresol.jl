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
sub = Vector{SubStation}() #Les substations qu'on va construire

function find_nearest_substation(instance::Instance)
    nearest_substations = Vector{SubStation}()
    
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

