function out = mergeIssues(app, a, b)
out = a;
if ~b.ok
    out.ok = false;
    out.messages = [a.messages, b.messages];
end
end
