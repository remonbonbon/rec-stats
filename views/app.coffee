"use strict"

vm = new Vue({
  el: '#app',
  data: {
    storage: {},
    reserves: [],
  },
  created: ->
    _this = this
    $.ajax("storage.json", {
      success: (json)->
        _this.$set("storage", json)
    })
    $.ajax("reserves.json", {
      success: (json)->
        _this.$set("reserves", json)
    })
})


# グラフ
margin = {top: 10, right: 50, bottom: 20, left: 50}
width = $(document.body).width() - margin.left - margin.right
height = 400 - margin.top - margin.bottom

parseDate = d3.time.format("%Y-%m-%d %H:%M:%S").parse
xAxisFormat = d3.time.format("%-m/%-d %-Hh")

x = d3.time.scale().range([0, width])
y = d3.scale.linear().range([height, 0])
y2 = d3.scale.linear().range([height, 0])
y_bar = d3.scale.linear().range([height, 0])
xAxis = d3.svg.axis().scale(x).orient("bottom").tickFormat(xAxisFormat).ticks(10)
yAxis = d3.svg.axis().scale(y).orient("right").ticks(20)
y2Axis = d3.svg.axis().scale(y2).orient("left").tickFormat((d)-> d + '%')
color = d3.scale.category20c()
  .domain([
    "cpu",
    "ssd",
    "room",
    null,  # offset for orange color-zone
    "diff",
    "humi"])

# グラフの線
line_cpu  = d3.svg.line().interpolate("step-after").x((d)-> x(d.time)).y((d)-> y(d.cpu))
line_ssd  = d3.svg.line().interpolate("step-after").x((d)-> x(d.time)).y((d)-> y(d.ssd))
line_room = d3.svg.line().interpolate("step-after").x((d)-> x(d.time)).y((d)-> y(d.room))
line_humi = d3.svg.line().interpolate("step-after").x((d)-> x(d.time)).y((d)-> y2(d.humi))
line_diff = d3.svg.line().interpolate("step-after").x((d)-> x(d.time)).y((d)-> y2(d.cpu - d.room))

svg = d3.select("#graph").append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

$.ajax("machine-status.json", {
  success: (data)->
    for d in data
      d.time = parseDate(d.time)
      d.hddstate = if d.hddstate == "standby" then 1 else 0
      d.recording = if d.recording == "standby" then 1 else 0

    x.domain(d3.extent(data, (d)-> d.time))
    y.domain([
      d3.min(data, (d)-> d3.min([d.cpu, d.ssd, d.room])) - 0.5,
      d3.max(data, (d)-> d3.max([d.cpu, d.ssd, d.room])) + 0.5
    ])
    y2.domain([0, 100])
    y_bar.domain([0, 1])

    bar_width = (x(parseDate("2015-01-01 00:15:00")) - x(parseDate("2015-01-01 00:00:00")))
    bar = svg.selectAll(".bar").data(data)
    # HDD状態のバー
    bar.enter().append("rect")
      .attr("class", "bar hddstate")
      .attr("x", (d)-> x(d.time))
      .attr("y", 0)
      .attr("width", bar_width)
      .attr("height", (d)-> y_bar(d.hddstate))
    # 録画状態のバー
    bar.enter().append("rect")
      .attr("class", "bar recording")
      .attr("x", (d)-> x(d.time))
      .attr("y", 0)
      .attr("width", bar_width)
      .attr("height", (d)-> y_bar(d.recording))

    # CPU温度のグラフ
    svg.append("path")
      .datum(data)
      .attr("class", "line")
      .attr("d", line_cpu)
      .style("stroke", (d)-> color("cpu"))

    # SSD温度のグラフ
    # svg.append("path")
      # .datum(data)
      # .attr("class", "line")
      # .attr("d", line_ssd)
      # .style("stroke", (d)-> color("ssd"))

    # 室温のグラフ
    svg.append("path")
      .datum(data)
      .attr("class", "line")
      .attr("d", line_room)
      .style("stroke", (d)-> color("room"))

    # CPUと室温の差分グラフ
    svg.append("path")
      .datum(data)
      .attr("class", "line")
      .attr("d", line_diff)
      .style("stroke", (d)-> color("diff"))

    # 湿度のグラフ
    svg.append("path")
      .datum(data)
      .attr("class", "line")
      .attr("d", line_humi)
      .style("stroke", (d)-> color("humi"))

    # X軸
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)

    # Y軸 (右軸, 温度)
    svg.append("g")
      .attr("class", "y axis")
      .attr('transform', "translate(#{width} ,0)")
      .call(yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", -12)
      .attr("dy", ".5em")
      .style("text-anchor", "end")
      .text("temp.")

    # Y軸 (左軸, 湿度)
    svg.append("g")
      .attr("class", "y axis")
      .call(y2Axis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("humidity")
})
