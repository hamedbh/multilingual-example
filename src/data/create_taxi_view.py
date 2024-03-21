# -*- coding: utf-8 -*-
from jinja2 import Template


def create_taxi_view(duck_conn, parquet_dir, view_name):
    """
    Function to create a view from the taxi data"""
    create_view_sql = Template(
        """
        CREATE VIEW {{ view_name }} AS
        SELECT *
        FROM read_parquet(
            '{{ parquet_dir }}/**/*.parquet',
            hive_partitioning=true
        )
        """
    ).render(parquet_dir=parquet_dir, view_name=view_name)
    duck_conn.execute(create_view_sql)
