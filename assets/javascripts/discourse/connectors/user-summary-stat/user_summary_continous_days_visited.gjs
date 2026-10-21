import DUserStat from "discourse/ui-kit/d-user-stat";

<template>
  <li class="user-summary-stat-outlet user_summary_continous_days_visited">
    <DUserStat
      @value={{@model.continous_days_visited}}
      @label="continous_days_visited"
    />
  </li>
</template>
