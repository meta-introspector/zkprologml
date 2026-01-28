// Tau-Prolog integration for zkPrologML

class TauPrologEngine {
  constructor() {
    this.session = pl.create();
    this.initialized = false;
  }

  async init() {
    // Load facts
    await fetch("tau_facts.js")
      .then(r => r.text())
      .then(facts => {
        this.session.consult(facts);
        this.initialized = true;
        console.log("✅ Tau-Prolog initialized");
      });
  }

  query(goal) {
    return new Promise((resolve, reject) => {
      this.session.query(goal);
      const results = [];
      this.session.answers(x => {
        if (x === false) resolve(results);
        else if (pl.type.is_error(x)) reject(x);
        else results.push(x);
      });
    });
  }

  async queryShard(shard) {
    const goal = `by_shard(${shard}, Path)`;
    return await this.query(goal);
  }

  async queryLanguage(lang) {
    const goal = `by_language(${lang}, Path)`;
    return await this.query(goal);
  }

  async provenTheorems() {
    const goal = "proven_theorems(Name)";
    return await this.query(goal);
  }
}

// Global instance
const tauProlog = new TauPrologEngine();
