using sail_route, Test, Dates

function circular_performance()
    twa = [a for a in LinRange(40.0, 180.0, 10)]
    tws = [10.0, 15.0]
    perf = fill(5.0, 10, 2)
    perf[:, 2] .= 7.5
    polar = sail_route.setup_perf_interpolation(tws, twa, perf)
    performance = sail_route.Performance(polar, 1.0, 1.0, nothing)
    return performance
end


lon1 = 0.0
lon2 = 10.0
lat = 0.0
dist, theta = sail_route.haversine(lon1, lat, lon2, lat)
wind_spd = 10.0
wind_dir = 0.0
curr_spd = 0.0
curr_dir = 0.0
bearing = sail_route.min_angle(theta, wind_dir)
v_t = dist/sail_route.perf_interp(circular_performance(), bearing, wind_spd)
println(v_t)

n_nodes = 11
test_route = sail_route.Route(lon1, lon2, lat, lat, n_nodes, n_nodes)

#create times 
start_time = Dates.DateTime(2019,7,9,0,0,0)
times = start_time:Dates.Hour(1):Dates.DateTime(2019,7,10,0,0,0)

# create weather data
wisp = fill(wind_spd, n_nodes, n_nodes, length(times))
widi = fill(wind_dir, n_nodes, n_nodes, length(times))
wadi = fill(0.0, n_nodes, n_nodes, length(times))
wahi = fill(0.0, n_nodes, n_nodes, length(times))
cusp = fill(curr_spd, n_nodes, n_nodes, length(times))
cudi = fill(curr_dir, n_nodes, n_nodes, length(times))

# provide environment


x = LinRange(0.5, 9.5, n_nodes)
y = LinRange(-5.0, 5.0, n_nodes)
grid_x = [i for i in x, j in y]
grid_y = [j for i in x, j in y]


# solve the route
rs = sail_route.route_solve(test_route, circular_performance(), start_time, times, grid_x, grid_y, wisp, widi, wadi, wahi, cusp, cudi)
println(rs)


@testset "Test straight line shortest path solution" begin
    lon1 = 0.0
    lon2 = 10.0
    lat = 0.0
    dist, theta = sail_route.haversine(lon1, lat, lon2, lat)
    wind_spd = 10.0
    wind_dir = 0.0
    curr_spd = 0.0
    curr_dir = 0.0
    bearing = sail_route.min_angle(theta, wind_dir)
    vt = dist/sail_route.perf_interp(circular_performance(), bearing, wind_spd)

    n_nodes = 11
    test_route = sail_route.Route(lon1, lon2, lat, lat, n_nodes, n_nodes)

    #create times 
    start_time = Dates.DateTime(2019,7,9,0,0,0)
    times = start_time:Dates.Hour(1):Dates.DateTime(2019,7,10,0,0,0)

    # create weather data
    wisp = fill(wind_spd, n_nodes, n_nodes, length(times))
    widi = fill(wind_dir, n_nodes, n_nodes, length(times))
    wadi = fill(0.0, n_nodes, n_nodes, length(times))
    wahi = fill(0.0, n_nodes, n_nodes, length(times))
    cusp = fill(curr_spd, n_nodes, n_nodes, length(times))
    cudi = fill(curr_dir, n_nodes, n_nodes, length(times))

    # provide environment


    x = LinRange(0.5, 9.5, n_nodes)
    y = LinRange(-5.0, 5.0, n_nodes)
    grid_x = [i for i in x, j in y]
    grid_y = [j for i in x, j in y]


    # solve the route
    rs = sail_route.route_solve(test_route, circular_performance(), start_time, times, grid_x, grid_y, wisp, widi, wadi, wahi, cusp, cudi)
    @test rs[1] ≈ vt
end