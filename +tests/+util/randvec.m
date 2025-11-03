function v = randvec(n, seed)
if nargin < 2, seed = 1; end
rng(seed);
v = randn(n, 1);
end
