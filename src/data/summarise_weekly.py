# -*- coding: utf-8 -*-
import click
import logging
from pathlib import Path
from dotenv import find_dotenv, load_dotenv
import duckdb
from jinja2 import Template
from src.data.create_taxi_view import create_taxi_view


@click.command()
@click.argument("parquet_dir", type=click.Path(exists=True))
@click.argument("output_path", type=click.Path())
def summarise_weekly(parquet_dir, output_path):
    """
    Function to summarise the taxi data by week"""

    logger = logging.getLogger(__name__)

    write_csv_sql = Template(
        """
        COPY (
          SELECT
            year,
            week(tpep_pickup_datetime) AS week,
            MIN(tpep_pickup_datetime)::date AS week_start,
            count(*) as trips,
            AVG(total_amount) AS avg_cost
          FROM all_taxi
          WHERE year = year(tpep_pickup_datetime)
          GROUP BY ALL
          ORDER BY ALL
        ) TO '{{ output_path }}' (FORMAT CSV, HEADER)
        """
    ).render(output_path=output_path)
    logger.info("Summarising taxi data by week")
    with duckdb.connect() as duck:
        create_taxi_view(duck, parquet_dir, "all_taxi")
        duck.execute(write_csv_sql)

    logger.info(f"Written weekly summary to {output_path}")


if __name__ == "__main__":
    log_fmt = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    logging.basicConfig(level=logging.INFO, format=log_fmt)

    # not used in this stub but often useful for finding various files
    project_dir = Path(__file__).resolve().parents[2]

    # find .env automagically by walking up directories until it's found, then
    # load up the .env entries as environment variables
    load_dotenv(find_dotenv())

    summarise_weekly()
