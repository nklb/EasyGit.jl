module EasyGit

using Dates

export gitstaginginfo, gitisclean, githead, gitshorthead, githeadtime


function gitverify(repfolder::String=".")
    try
        read(`command -v git`)
    catch 
        error("git is not installed.")
    end
    try
        read(`git -C $repfolder rev-parse --is-inside-work-tree`)
    catch 
        error("Not a git repository.")
    end
    true
end


"""
    gitstaginginfo(repfolder::String=".")
Get modified and untracked files of a git repository as String vectors.
"""
function gitstaginginfo(repfolder::String=".")
    gitverify(repfolder)
    status = split(readchomp(`git -C $repfolder status --porcelain`), "\n")
    modified = String[]
    untracked = String[]
    for entry in status
        if length(entry) < 2
            continue
        elseif entry[1:2] == " M"
            push!(modified, entry[4:end])
        elseif entry[1:2] == "??"
            push!(untracked, entry[4:end])
        end
    end
    modified, untracked
end


"""
    gitisclean(repfolder::String=".")
Is true if there are no modified and no untracked files in the repository that are not 
yet committed (or ignored). 
"""
function gitisclean(repfolder::String=".")
    modified, untracked = gitstaginginfo(repfolder)
    isempty(modified) & isempty(untracked)
end


"""
    githead(repfolder::String=".")
Get hash of the repository head.
"""
function githead(repfolder::String=".")
    gitverify(repfolder)
    readchomp(`git -C $repfolder rev-parse HEAD`)
end


"""
    githead(repfolder::String=".")
Get short hash of the repository head.
"""
function gitshorthead(repfolder::String=".")
    hid = githead(repfolder)
    hid[1:7]
end


"""
    githeadtime(repfolder::String=".")
Get date and time of the last commit.
"""
function githeadtime(repfolder::String=".")
    gitverify(repfolder)
    htime_unix = readchomp(`git show -s --format=%ct HEAD`)
    unix2datetime(parse(Int64, htime_unix))
end

end
