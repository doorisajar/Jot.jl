@with_kw mutable struct Labels
  RESPONDER_PACKAGE_NAME::String = ""
  RESPONDER_FUNCTION_NAME::String = ""
  RESPONDER_COMMIT::Union{Nothing, String} = nothing
  RESPONDER_TREE_HASH::String = ""
  RESPONDER_PKG_SOURCE::Union{Nothing, String} = nothing
  IS_JOT_GENERATED::String = "false" # set to "true" in get_labels(res)
  user_defined_labels::Dict{String, String} = Dict{String, String}()
end
StructTypes.StructType(::Type{Labels}) = StructTypes.Mutable()  

function copy(l::Labels)::Labels
  flds = Dict(Symbol(fn) => getfield(l, fn) for fn in fieldnames(Labels))
  Labels(;flds...)
end

function get_responder_full_function_name(labels::Labels)::String
  labels.RESPONDER_PACKAGE_NAME * "." * labels.RESPONDER_FUNCTION_NAME
end

function to_aws_shorthand(l::Labels)::String
  normal_tags = join(["$k=$(getfield(l, k))" for k in fieldnames(Labels)], ",")
  addnl_tags = join(["$k=$v" for (k,v) in l.user_defined_labels], ",")
  normal_tags * "," * addnl_tags
end

function to_docker_buildfile_format(l::Labels)::String
  normal_labels = join(
    ["$(String(k))=$(getfield(l, k))" for k in fieldnames(Labels) if k != :user_defined_labels], 
    " ",
  )
  user_defined_labels = join(["$k=$v" for (k, v) in l.user_defined_labels], " ") 
  normal_labels * " " * user_defined_labels
end

function add_user_defined_labels(l::Labels, new_tags::Dict{String, String})::Labels
  c_l = copy(l)
  c_l.user_defined_labels = merge(c_l.user_defined_labels, new_tags)
  c_l
end

