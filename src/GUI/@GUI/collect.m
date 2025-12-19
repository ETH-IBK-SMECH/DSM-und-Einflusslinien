function issues = collect(app, issues, fcn)
try
    fcn();
catch ME
    issues.ok = false;
    issues.messages{end+1} = ME.message;
end
end