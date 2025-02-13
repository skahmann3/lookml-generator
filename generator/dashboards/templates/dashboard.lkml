- dashboard: {{name}}
  title: {{title}}
  layout: {{layout}}
  preferred_viewer: dashboards-next

  elements:
  {% for element in elements -%}
  - title: {{element.title}}
    name: {{element.title}}
    explore: {{element.explore}}
    type: "ci-line-chart"
    fields: [
      {{element.explore}}.{{element.xaxis}},
      {{element.explore}}.branch,
      {{element.explore}}.high,
      {{element.explore}}.low,
      {{element.explore}}.percentile
    ]
    pivots: [
      {{element.explore}}.branch 
      {%- if group_by_dimension and element.title.endswith(group_by_dimension) %}, {{element.explore}}.{{group_by_dimension}} {% endif %}
    ]
    {% if not compact_visualization -%}
    filters:
      {{element.explore}}.probe: {{element.metric}}
    {% endif -%}
    row: {{element.row}}
    col: {{element.col}}
    width: 12
    height: 8
    field_x: {{element.explore}}.{{element.xaxis}}
    field_y: {{element.explore}}.percentile
    log_scale: false
    ci_lower: {{element.explore}}.low
    ci_upper: {{element.explore}}.high
    show_grid: true
    listen:
      Percentile: {{element.explore}}.percentile_conf
      {%- for dimension in dimensions %}
      {{dimension.title}}: {{element.explore}}.{{dimension.name}}
      {%- endfor %}
      {% if compact_visualization -%}
      Probe: {{element.explore}}.probe
      {% endif -%}
    {%- for branch, color in element.series_colors.items() %}
    {{ branch }}: "{{ color }}"
    {%- endfor %}
    defaults_version: 0
  {% endfor -%}
  {% if alerts is not none %}
  - title: Alerts
    name: Alerts
    model: operational_monitoring
    explore: {{alerts.explore}}
    type: looker_grid
    fields: [{{alerts.explore}}.submission_date,
      {{alerts.explore}}.probe, {{alerts.explore}}.percentile,
      {{alerts.explore}}.message, {{alerts.explore}}.branch, {{alerts.explore}}.errors]
    sorts: [{{alerts.explore}}.submission_date
        desc]
    limit: 500
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    defaults_version: 1
    series_types: {}
    listen: {}
    row: {{ alerts.row }}
    col: {{ alerts.col }}
    width: 24
    height: 6
  {% endif %}
  filters:
  - name: Percentile
    title: Percentile
    type: number_filter
    default_value: '50'
    allow_multiple_values: false
    required: true
    ui_config:
      type: dropdown_menu
      display: inline
      options:
      - '10'
      - '20'
      - '30'
      - '40'
      - '50'
      - '60'
      - '70'
      - '80'
      - '90'
      - '95'
      - '99'
  {% if compact_visualization -%}
  - name: Probe
    title: Probe
    type: field_filter
    default_value: '{{ elements[0].metric }}'
    allow_multiple_values: true
    required: true
    ui_config:
      type: dropdown_menu
      display: popover
    model: operational_monitoring
    explore: {{ elements[0].explore }}
    listens_to_filters: []
    field: {{ elements[0].explore }}.probe
  {% endif -%}

  {% for dimension in dimensions -%}
  {% if dimension.name != group_by_dimension %}
  - title: {{dimension.title}}
    name: {{dimension.title}}
    type: string_filter
    default_value: '{{dimension.default}}'
    allow_multiple_values: false
    required: true
    ui_config:
      type: dropdown_menu
      display: inline
      options:
      {% for option in dimension.options -%}
      - '{{option}}'
      {% endfor %}
  {% else %}
  - title: {{dimension.title}}
    name: {{dimension.title}}
    type: string_filter
    default_value: '{% for option in dimension.options | sort -%}{{option}}{% if not loop.last %},{% endif %}{% endfor %}'
    allow_multiple_values: true
    required: true
    ui_config:
      type: advanced
      display: inline
      options:
      {% for option in dimension.options | sort -%}
      - '{{option}}'
      {% endfor %}
    {% endif %}
  {% endfor -%}
