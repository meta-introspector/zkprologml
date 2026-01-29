// Bootstrap JSON to Parquet converter
use anyhow::Result;
use parquet::{
    file::properties::WriterProperties,
    record::RecordWriter,
};
use serde::{Deserialize, Serialize};
use std::fs::File;
use std::sync::Arc;

#[derive(Debug, Serialize, Deserialize)]
struct BootstrapResults {
    completeness: f64,
    self_awareness: i32,
    module_count: i32,
    card_count: i32,
    cards: Vec<IndexCard>,
}

#[derive(Debug, Serialize, Deserialize)]
struct IndexCard {
    term: String,
    definition: String,
    references: i32,
    chord: i32,
}

fn main() -> Result<()> {
    let args: Vec<String> = std::env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <input.json> <output.parquet>", args[0]);
        std::process::exit(1);
    }

    let input_path = &args[1];
    let output_path = &args[2];

    // Read JSON
    let json_data = std::fs::read_to_string(input_path)?;
    let results: BootstrapResults = serde_json::from_str(&json_data)?;

    println!("📊 Converting {} cards to parquet...", results.card_count);

    // Write parquet (simplified - using arrow)
    use arrow::array::{Float64Array, Int32Array, StringArray};
    use arrow::datatypes::{DataType, Field, Schema};
    use arrow::record_batch::RecordBatch;
    use parquet::arrow::ArrowWriter;

    let schema = Schema::new(vec![
        Field::new("term", DataType::Utf8, false),
        Field::new("definition", DataType::Utf8, false),
        Field::new("references", DataType::Int32, false),
        Field::new("chord", DataType::Int32, false),
    ]);

    let terms: Vec<String> = results.cards.iter().map(|c| c.term.clone()).collect();
    let defs: Vec<String> = results.cards.iter().map(|c| c.definition.clone()).collect();
    let refs: Vec<i32> = results.cards.iter().map(|c| c.references).collect();
    let chords: Vec<i32> = results.cards.iter().map(|c| c.chord).collect();

    let batch = RecordBatch::try_new(
        Arc::new(schema.clone()),
        vec![
            Arc::new(StringArray::from(terms)),
            Arc::new(StringArray::from(defs)),
            Arc::new(Int32Array::from(refs)),
            Arc::new(Int32Array::from(chords)),
        ],
    )?;

    let file = File::create(output_path)?;
    let mut writer = ArrowWriter::try_new(file, Arc::new(schema), None)?;
    writer.write(&batch)?;
    writer.close()?;

    println!("✅ Wrote {} cards to {}", results.card_count, output_path);
    println!("📈 Completeness: {:.2}%", results.completeness * 100.0);
    println!("🧠 Self-awareness: {}/7", results.self_awareness);

    Ok(())
}
